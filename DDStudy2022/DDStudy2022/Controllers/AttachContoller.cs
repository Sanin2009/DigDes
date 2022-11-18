using Api.Consts;
using Api.Models.Attach;
using Api.Services;
using Common;
using Common.Extentions;
using DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace Api.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class AttachController : ControllerBase
    {
        private readonly UserService _userService;
        private readonly PostService _postService;

        public AttachController(UserService userService, PostService postService)
        {
            _userService = userService;
            _postService = postService; 
        }

        [HttpPost]
        public async Task<List<MetadataModel>> UploadFiles([FromForm] List<IFormFile> files)
        {
            var res = new List<MetadataModel>();
            foreach (var file in files)
            {
                res.Add(await UploadFile(file));
            }
            return res;
        }

        [HttpPost]
        [Authorize]
        public async Task AddAvatarToUser(MetadataModel model)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            if (userId == default)
            {
                var tempFi = new FileInfo(Path.Combine(Path.GetTempPath(), model.TempId.ToString()));
                if (!tempFi.Exists)
                    throw new NotFound("file");
                else
                {
                    var path = Path.Combine(Directory.GetCurrentDirectory(), "attaches", model.TempId.ToString());
                    var destFi = new FileInfo(path);
                    if (destFi.Directory != null && !destFi.Directory.Exists)
                        destFi.Directory.Create();

                    System.IO.File.Copy(tempFi.FullName, path, true);

                    await _userService.AddAvatarToUser(userId, model, path);
                }
            }
            else
                throw new NoAccess();

        }

        [HttpGet]
        [Authorize]
        public async Task<FileResult> GetAttach(Guid attachId)
        {
            // Access check (may be?)
            var attach = await _postService.GetAttach(attachId);
            return File(System.IO.File.ReadAllBytes(attach.FilePath), attach.MimeType);
        }

        [HttpGet]
        [Authorize]
        public async Task<FileResult> GetUserAvatar(Guid userId)
        {
            // Free access
            var attach = await _userService.GetAllUserAvatars(userId);
            if (attach.IsNullOrEmpty()) return File(System.IO.File.ReadAllBytes(Directory.GetCurrentDirectory() + "\\attaches\\404"), "image/jpeg");
            else return File(System.IO.File.ReadAllBytes(attach[0].FilePath), attach[0].MimeType);
        }

        [HttpGet]
        [Authorize]
        public async Task<List<string>> GetAllUserAvatars(Guid userId)
        {
            // Access check (may be?)
            var image = await _userService.GetAllUserAvatars(userId);
            var result = new List<string>();
            foreach (AttachModel model in image)
                result.Add(LinkHelper.Attach(model.Id));
            return result;
        }



        private async Task<MetadataModel> UploadFile(IFormFile file)
        {
            var tempPath = Path.GetTempPath();
            var meta = new MetadataModel
            {
                TempId = Guid.NewGuid(),
                Name = file.FileName,
                MimeType = file.ContentType,
                Size = file.Length,
            };

            var newPath = Path.Combine(tempPath, meta.TempId.ToString());

            var fileinfo = new FileInfo(newPath);
            if (fileinfo.Exists)
            {
                throw new Exception("file exist");
            }
            else
            {
                if (fileinfo.Directory == null)
                {
                    throw new Exception("temp is null");
                }
                else
                if (!fileinfo.Directory.Exists)
                {
                    fileinfo.Directory?.Create();
                }

                using (var stream = System.IO.File.Create(newPath))
                {
                    await file.CopyToAsync(stream);
                }
                return meta;
            }

        }
    }
}
