using AutoMapper.QueryableExtensions;
using DAL;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Api.Services;
using DAL.Entities;
using Api.Models.Attach;
using Api.Models.Post;
using Api.Models.User;
using Api.Models.Comment;

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
        







        //[HttpGet]
        //public async Task<FileResult> DownloadAvatar(Guid avatarId)
        //{
        //    var attach = await _userService.GetUserAvatar(avatarId);

        //    HttpContext.Response.ContentType = attach.MimeType;
        //    FileContentResult result = new FileContentResult(System.IO.File.ReadAllBytes(attach.FilePath), attach.MimeType)
        //    {
        //        FileDownloadName = attach.Name
        //    };

        //    return result;
        //}

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
