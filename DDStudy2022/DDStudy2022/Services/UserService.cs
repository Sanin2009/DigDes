using Api.Configs;
using Api.Consts;
using Api.Models.Attach;
using Api.Models.Comment;
using Api.Models.Post;
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

        public async Task<List<AttachModel>> GetAllUserAvatars(Guid userId)
        {
            return await _context.Avatars.Where(x=>x.UserId ==userId).AsNoTracking().ProjectTo<AttachModel>(_mapper.ConfigurationProvider).ToListAsync(); 
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

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
