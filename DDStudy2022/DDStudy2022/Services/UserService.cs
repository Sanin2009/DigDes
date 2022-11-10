﻿using Api.Configs;
using Api.Models;
using Api.Models.Attach;
using Api.Models.Token;
using Api.Models.User;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Common;
using DAL;
using DAL.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Api.Services
{
    public class UserService : IDisposable
    {
        private readonly IMapper _mapper;
        private readonly DAL.DataContext _context;
        private readonly AuthConfig _config;

        public UserService(IMapper mapper, IOptions<AuthConfig> config, DataContext context)
        {
            _mapper = mapper;
            _context = context;
            _config = config.Value;

        }

        public async Task<bool> CheckUserExist(string email)
        {

            return await _context.Users.AnyAsync(x => x.Email.ToLower() == email.ToLower());

        }

        public async Task AddAvatarToUser(Guid userId, MetadataModel meta, string filePath)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user != null)
            { 
                var newAvatar = await _context.Avatars.AddAsync( new Avatar 
                { 
                    UserId=userId, 
                    MimeType = meta.MimeType, 
                    FilePath = filePath, 
                    Name = meta.Name, 
                    Size = meta.Size 
                });

                await _context.SaveChangesAsync();
            }

        }

        public async Task<UserPost> CreatePost (Guid userId, string Title)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null) throw new Exception("user not found");
            //var newpost = new UserPost { UserId=userId, Name=Title, Created=DateTimeOffset.Now};
            var newpost = await _context.UserPosts.AddAsync(new DAL.Entities.UserPost
            {
                UserId=userId,
                User = user,
                Name = Title,
                Created = DateTime.UtcNow,
                Id = Guid.NewGuid()
            });
            await _context.SaveChangesAsync();
            return newpost.Entity;
        }

        public async Task<Comment> AddComment(string userId, Guid postId, string msg)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == Guid.Parse(userId));
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => x.Id == postId);
            if (user == null) throw new Exception("user not found");
            if (post == null) throw new Exception("post not found");
            var newcomment = await _context.Comments.AddAsync(new DAL.Entities.Comment
            {
                User = user,
                UserPost = post,
                Created = DateTime.UtcNow,
                Id = Guid.NewGuid(),
                Message = msg,
            });
            await _context.SaveChangesAsync();
            return newcomment.Entity;
        }

        public async Task<List<ShowCommentModel>> ShowComments(Guid postId)
        {
            var t = await _context.Comments.Where(x => x.UserPostId == postId).ToListAsync();
            var result = new List<ShowCommentModel>();
            foreach (var temp in t)
            {
                var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == temp.UserId);
                if (user == null) break;
                var comment = new ShowCommentModel(temp.Id, user.Name, temp.Message, temp.Created);
                result.Add(comment);
            }
            return result;
        }

        public async Task AddImageToPost(Guid userId, UserPost postId, MetadataModel model, string filepath)
        {
            var user = await _context.Users.Include(x => x.Avatar).FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null) throw new Exception("User not found");
            var newimage = await _context.PostImages.AddAsync(new DAL.Entities.PostImage
            {
                UserPostId = postId.Id,
                User = user,
                MimeType = model.MimeType,
                FilePath = filepath,
                Name = model.Name,
                Size = model.Size
            });
            await _context.SaveChangesAsync();
        }

        

        public async Task<List<AttachModel>> GetAllUserAvatars(Guid userId)
        {
            return await _context.Avatars.Where(x=>x.UserId ==userId).AsNoTracking().ProjectTo<AttachModel>(_mapper.ConfigurationProvider).ToListAsync(); //. Aggregate(x => x.Id == postId);
        }

        public async Task<List<AttachModel>> GetPost(Guid postId)
        {
            return await _context.PostImages.Include(x => x.UserPost).Where(x =>x.UserPostId == postId).AsNoTracking().ProjectTo<AttachModel>(_mapper.ConfigurationProvider).ToListAsync(); //. Aggregate(x => x.Id == postId);
        }

        public async Task<List<UserPost>> GetIdPosts()
        {
            return await _context.UserPosts.ToListAsync();
        }

        public async Task<AttachModel> GetPostImage(Guid attachId)
        {
            var attachT = await _context.Attaches.FirstOrDefaultAsync(x => x.Id == attachId);
            //var user = await GetUserById(userId);
            var attach = _mapper.Map<AttachModel>(attachT);
            if (attach == null) throw new Exception("image not found");
            return attach;
        }

        public async Task<AttachModel> GetUserAvatar(Guid attachId)
        {
            var user = await _context.Avatars.FirstOrDefaultAsync(x => x.Id == attachId);
            if (user == null) throw new Exception("user not found");
            //var user = await GetUserById(userId);
            var attach = _mapper.Map<AttachModel>(user);
            if (attach == null) throw new Exception("avatar not found");
            return attach;
        }

        public async Task Delete(Guid id)
        {
            var dbUser = await GetUserById(id);
            if (dbUser != null)
            {
                _context.Users.Remove(dbUser);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<Guid> CreateUser(CreateUserModel model)
        {
            var dbUser = _mapper.Map<DAL.Entities.User>(model);
            var t = await _context.Users.AddAsync(dbUser);
            await _context.SaveChangesAsync();
            return t.Entity.Id;
        }
        public async Task<List<UserModel>> GetUsers()
        {
            return await _context.Users.AsNoTracking().ProjectTo<UserModel>(_mapper.ConfigurationProvider).ToListAsync();
        }

        private async Task<DAL.Entities.User> GetUserById(Guid id)
        {
            var user = await _context.Users.Include(x => x.Avatar).FirstOrDefaultAsync(x => x.Id == id);
            if (user == null)
                throw new Exception("user not found");
            return user;
        }
        public async Task<UserModel> GetUser(Guid id)
        {
            var user = await GetUserById(id);

            return _mapper.Map<UserModel>(user);

        }

        private async Task<DAL.Entities.User> GetUserByCredention(string login, string pass)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Email.ToLower() == login.ToLower());
            if (user == null)
                throw new Exception("user not found");

            if (!HashHelper.Verify(pass, user.PasswordHash))
                throw new Exception("password is incorrect");

            return user;
        }

        private TokenModel GenerateTokens(DAL.Entities.UserSession session)
        {
            var dtNow = DateTime.Now;
            if (session.User == null)
                throw new Exception("magic");

            var jwt = new JwtSecurityToken(
                issuer: _config.Issuer,
                audience: _config.Audience,
                notBefore: dtNow,
                claims: new Claim[] {
            new Claim(ClaimsIdentity.DefaultNameClaimType, session.User.Name),
            new Claim("sessionId", session.Id.ToString()),
            new Claim("id", session.User.Id.ToString()),
            },
                expires: DateTime.Now.AddMinutes(_config.LifeTime),
                signingCredentials: new SigningCredentials(_config.SymmetricSecurityKey(), SecurityAlgorithms.HmacSha256)
                );
            var encodedJwt = new JwtSecurityTokenHandler().WriteToken(jwt);

            var refresh = new JwtSecurityToken(
                notBefore: dtNow,
                claims: new Claim[] {
                new Claim("refreshToken", session.RefreshToken.ToString()),
                },
                expires: DateTime.Now.AddHours(_config.LifeTime),
                signingCredentials: new SigningCredentials(_config.SymmetricSecurityKey(), SecurityAlgorithms.HmacSha256)
                );
            var encodedRefresh = new JwtSecurityTokenHandler().WriteToken(refresh);

            return new TokenModel(encodedJwt, encodedRefresh);

        }
        public async Task<TokenModel> GetToken(string login, string password)
        {
            var user = await GetUserByCredention(login, password);
            var session = await _context.UserSessions.AddAsync(new DAL.Entities.UserSession
            {
                User = user,
                RefreshToken = Guid.NewGuid(),
                Created = DateTime.UtcNow,
                Id = Guid.NewGuid()
            });
            await _context.SaveChangesAsync();
            return GenerateTokens(session.Entity);
        }

        public async Task<UserSession> GetSessionById(Guid id)
        {
            var session = await _context.UserSessions.FirstOrDefaultAsync(x => x.Id == id);
            if (session == null)
            {
                throw new Exception("session is not found");
            }
            return session;
        }
        private async Task<UserSession> GetSessionByRefreshToken(Guid id)
        {
            var session = await _context.UserSessions.Include(x => x.User).FirstOrDefaultAsync(x => x.RefreshToken == id);
            if (session == null)
            {
                throw new Exception("session is not found");
            }
            return session;
        }

        public async Task<TokenModel> GetTokenByRefreshToken(string refreshToken)
        {
            var validParams = new TokenValidationParameters
            {
                ValidateAudience = false,
                ValidateIssuer = false,
                ValidateIssuerSigningKey = true,
                ValidateLifetime = true,
                IssuerSigningKey = _config.SymmetricSecurityKey()
            };
            var principal = new JwtSecurityTokenHandler().ValidateToken(refreshToken, validParams, out var securityToken);

            if (securityToken is not JwtSecurityToken jwtToken
                || !jwtToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256,
                StringComparison.InvariantCultureIgnoreCase))
            {
                throw new SecurityTokenException("invalid token");
            }

            if (principal.Claims.FirstOrDefault(x => x.Type == "refreshToken")?.Value is String refreshIdString
                && Guid.TryParse(refreshIdString, out var refreshId)
                )
            {
                var session = await GetSessionByRefreshToken(refreshId);
                if (!session.IsActive)
                {
                    throw new Exception("session is not active");
                }


                session.RefreshToken = Guid.NewGuid();
                await _context.SaveChangesAsync();

                return GenerateTokens(session);
            }
            else
            {
                throw new SecurityTokenException("invalid token");
            }
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}