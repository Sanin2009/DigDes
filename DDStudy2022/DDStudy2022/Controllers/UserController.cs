using AutoMapper.QueryableExtensions;
using DAL;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Api.Services;
using Api.Models;
using DAL.Entities;

namespace Api.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly UserService _userService;

        public UserController(UserService userService)
        {
            _userService = userService;
        }

        [HttpPost]
        public async Task CreateUser(CreateUserModel model)
        {
            if (await _userService.CheckUserExist(model.Email))
                throw new Exception("user doesn't exist");
            await _userService.CreateUser(model);

        }
        [HttpGet]
        public async Task<List<UserPost>> GetIdPosts()
        {
            return await _userService.GetIdPosts();
        }

        [HttpPost]
        [Authorize]
        public async Task CreatePost (CreatePostModel createPostModel)
        {
            var userIdString = User.Claims.FirstOrDefault(x => x.Type == "id")?.Value;
            if (Guid.TryParse(userIdString, out var userId))
            {
                var post = await _userService.CreatePost(userId, createPostModel.Title);
                foreach (MetadataModel model in createPostModel.Metadata)
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
                        await _userService.AddImageToPost(userId, post, model, path);
                    }
                }

            }
        }

        [HttpPost]
        [Authorize]
        public async Task AddComment(Guid postId, string msg)
        {
            var userIdString = User.Claims.FirstOrDefault(x => x.Type == "id")?.Value;
            if (userIdString == null) throw new Exception("id not found");
            await _userService.AddComment(userIdString,postId,msg);
        }

        [HttpPost]
        public async Task<List<CommentModel>> ShowComments(Guid postId)
        {
            return await _userService.ShowComments(postId);
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
        public async Task<List<string>> GetPost(Guid postId)
        {
            var image = await _userService.GetPost(postId);
            var result = new List<string>();
            
            foreach (AttachModel model in image)
            {
                // HttpResponseMessage httpResponseMessage = await GetPostImage(model.Id);
                var t = model.Id;
                var urlString = "https://localhost:7191" + "/api/User/GetPostImage?attachId=" + t.ToString(); 
                result.Add(urlString);
            }
            return result;
        }

        [HttpGet]
        public async Task<FileResult> GetPostImage(long attachId)
        {
            var attach = await _userService.GetPostImage(attachId);

            return File(System.IO.File.ReadAllBytes(attach.FilePath), attach.MimeType);
        }


        [HttpGet]
        public async Task<FileResult> GetUserAvatar(Guid userId)
        {
            var attach = await _userService.GetUserAvatar(userId);

            return File(System.IO.File.ReadAllBytes(attach.FilePath), attach.MimeType);
        }

        [HttpGet]
        public async Task<FileResult> DownloadAvatar(Guid userId)
        {
            var attach = await _userService.GetUserAvatar(userId);

            HttpContext.Response.ContentType = attach.MimeType;
            FileContentResult result = new FileContentResult(System.IO.File.ReadAllBytes(attach.FilePath), attach.MimeType)
            {
                FileDownloadName = attach.Name
            };

            return result;
        }

        [HttpGet]
        [Authorize]
        public async Task<List<UserModel>> GetUsers() => await _userService.GetUsers();

        [HttpGet]
        [Authorize]
        public async Task<UserModel> GetCurrentUser()
        {
            var userIdString = User.Claims.FirstOrDefault(x => x.Type == "id")?.Value;
            if (Guid.TryParse(userIdString, out var userId))
            {

                return await _userService.GetUser(userId);
            }
            else
                throw new Exception("you are not authorized");

        }
    }
}
