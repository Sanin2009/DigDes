using Api.Models.Token;
using Api.Models.User;
using Api.Services;
using Common;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserService _userService;
        private readonly AuthService _authService;

        public AuthController(UserService userService, AuthService authService)
        {
            _userService = userService;
            _authService = authService;
        }

        [HttpPost]
        public async Task CreateUser(CreateUserModel model)
        {
            if (await _userService.CheckUserExist(model.Email))
                throw new NotFound("user");
            await _userService.CreateUser(model);

        }

        [HttpPost]
        public async Task<TokenModel> LoginUser(TokenRequestModel model)
        {
            return await _authService.GetToken(model.Login, model.Pass);
        }

        [HttpPost]
        public async Task<TokenModel> RefreshToken(RefreshTokenRequestModel model)
        {
            return await _authService.GetTokenByRefreshToken(model.RefreshToken);
        }

        [HttpGet]
        public async Task<bool> CheckNameExist(string name)
        {
            return await _userService.CheckNameExist(name);
        }

        [HttpGet]
        public async Task<bool> CheckMailExist(string mail)
        {
            return await _userService.CheckUserExist(mail);
        }
           
    }
}