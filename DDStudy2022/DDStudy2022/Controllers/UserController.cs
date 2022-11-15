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
using Api.Consts;
using Common.Extentions;

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

        [HttpGet]
        [Authorize]
        public async Task<List<UserModel>> GetUsers() => await _userService.GetUsers();

        [HttpGet]
        [Authorize]
        public async Task<UserModel> GetCurrentUser()
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.GetUser(userId);
        }
    }
}
