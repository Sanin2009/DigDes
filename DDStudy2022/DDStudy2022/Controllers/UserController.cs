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
        public async Task<List<UserModel>> SearchUsers(string? name) => await _userService.GetUsers(name);

        [HttpGet]
        [Authorize]
        public async Task<UserModel> GetUserById(Guid userId)
        {
            var subId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.GetUser(subId, userId);
        }

        [HttpGet]
        [Authorize]
        public async Task<UserModel> GetUserByName(string name)
        {
            var subId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.GetUserByName(subId, name);
        }

        [HttpGet]
        [Authorize]
        public async Task<UserModel> GetCurrentUser()
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.GetUser(userId, userId);
        }

        [HttpGet]
        [Authorize]
        public async Task <List<UserModel>> GetSubscriptions(Guid subscriberId)
        {
            //var subscriberId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.GetSubscriptions(subscriberId);
        }

        [HttpGet]
        [Authorize]
        public async Task<List<UserModel>> GetSubscribers(Guid userId)
        {
            //var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.GetSubscribers(userId);
        }

        [HttpGet]
        [Authorize]
        public async Task<List<UserModel>> GetSubRequests(Guid userId)
        {
            //var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.GetSubRequests(userId);
        }

        //[HttpGet]
        //[Authorize]
        //public async Task<int> GetUsersTotalSubs(Guid userId)
        //{
        //    return await _userService.GetUsersTotalSubs(userId);
        //}

        [HttpPut]
        [Authorize]
        public async Task<bool> UpdateSubRequests(Guid subscriberId, bool upd)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.UpdateSubRequest(subscriberId, userId, upd);
        }

        [HttpPut]
        [Authorize]
        public async Task<string?> UpdateStatus(string? status)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.UpdateStatus(userId, status);
        }

        [HttpPut]
        [Authorize]
        public async Task<bool> UpdateSettings(UpdateUserSettingsModel model)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.UpdateSettings(userId, model);
        }

        [HttpPut]
        [Authorize]
        public async Task<bool> Subscribe(Guid userId, bool sub)
        {
            var subscriberId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _userService.Subscribe(subscriberId, userId, sub);
        }



    }
}
