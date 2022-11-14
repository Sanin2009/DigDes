using Api.Models.Attach;
using Api.Services;
using Common;
using DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Api.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class AttachController : ControllerBase
    {
        private readonly UserService _userService;

        public AttachController(UserService userService)
        {
            _userService = userService;
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

        [HttpGet]
        public async Task<FileResult> GetAttach(Guid attachId)
        {
            // Access check (may be?)
            var attach = await _userService.GetAttach(attachId);

            return File(System.IO.File.ReadAllBytes(attach.FilePath), attach.MimeType);
        }

        [HttpGet]
        public async Task<FileResult> GetUserAvatar(Guid userId)
        {
            // Access all avatars
            var attach = await _userService.GetAllUserAvatars(userId);
            //var attach = await _userService.GetAttach(attachId);
            //return [0], I think
            return File(System.IO.File.ReadAllBytes(attach[0].FilePath), attach[0].MimeType);
        }

        [HttpPost]
        [Authorize]
        public async Task AddAvatarToUser(MetadataModel model)
        {
            var userIdString = User.Claims.FirstOrDefault(x => x.Type == "id")?.Value;
            if (Guid.TryParse(userIdString, out var userId))
            {
                var tempFi = new FileInfo(Path.Combine(Path.GetTempPath(), model.TempId.ToString()));
                if (!tempFi.Exists)
                    throw new Exception("file not found");
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
                throw new Exception("you are not authorized");

        }

        [HttpGet]
        public async Task<List<string>> GetAllUserAvatars(Guid userId)
        {
            // Access check (may be?)
            var image = await _userService.GetAllUserAvatars(userId);
            var result = new List<string>();

            foreach (AttachModel model in image)
            {
                result.Add(LinkHelper.Attach(model.Id));
                //var t = model.Id;
                //var urlString = "https://localhost:7191" + "/api/User/GetAttach?attachId=" + t.ToString();
                //result.Add(urlString);
            }
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
