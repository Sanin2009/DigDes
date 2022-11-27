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

        public async Task<bool> CheckNameExist(string name)
        {
            return await _context.Users.AnyAsync(x => x.Name.ToLower() == name.ToLower());
        }

        public async Task<string?> UpdateStatus( Guid userId, string? status)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null) throw new NotFound("user");
            user.Status = status;
            await _context.SaveChangesAsync();
            return status;
        }

        public async Task<bool> UpdateSettings(Guid userId, UpdateUserSettingsModel model)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null) throw new NotFound("user");
            user.IsOpen = model.IsOpen ;
            await _context.SaveChangesAsync();
            return model.IsOpen;
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
            var dbUser = await _context.Users.FirstOrDefaultAsync(x => x.Id == id);
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

        public async Task<List<UserModel>> GetUsers(string? name)
        {
            if (name == null) return await _context.Users.Where(x=>x.IsActive==true).AsNoTracking().ProjectTo<UserModel>(_mapper.ConfigurationProvider).ToListAsync();
            else return await _context.Users.Where(x=>(x.Name.ToLower().Contains(name.ToLower())) && (x.IsActive == true)).AsNoTracking().ProjectTo<UserModel>(_mapper.ConfigurationProvider).ToListAsync();
        }

        public async Task<UserModel> GetUser(Guid subId, Guid userid)
        {
            var user = await GetUserById(userid);
            var sub = await _context.Subscribers.FirstOrDefaultAsync(x => (x.SubscriberId == subId) && (x.UserId == userid));
            bool? isSub = sub?.IsSubscribed;
            user.isSub = isSub;
            return user;
        }

        public async Task<List<Guid>> GetSubscriptions(Guid subscriberId)
        {
            var subs = await _context.Subscribers.Where(x => (x.SubscriberId == subscriberId) && (x.IsSubscribed)).Select(x=>x.UserId).ToListAsync();
            if (subs.IsNullOrEmpty()) return new List<Guid>();
            else return subs;
        }

        public async Task<List<Guid>> GetSubscribers(Guid userId)
        {
            var subs = await _context.Subscribers.Where(x => (x.UserId == userId) && (x.IsSubscribed)).Select(x => x.SubscriberId).ToListAsync();
            if (subs.IsNullOrEmpty()) return new List<Guid>();
            else return subs;
        }

        public async Task<List<Guid>> GetSubRequests(Guid userId)
        {
            var subs = await _context.Subscribers.Where(x => (x.UserId == userId) && (x.IsSubscribed==false)).Select(x => x.SubscriberId).ToListAsync();
            if (subs.IsNullOrEmpty()) return new List<Guid>();
            else return subs;
        }
        public async Task<int> GetUsersTotalSubs(Guid userId)
        {
            return _context.Subscribers.Where(x => (x.UserId == userId) && (x.IsSubscribed == true)).Count();
        }
        

        public async Task<bool> UpdateSubRequest(Guid subscriberId, Guid userId, bool sub)
        {
            var isSub = await _context.Subscribers.FirstOrDefaultAsync(x => (x.SubscriberId == subscriberId) && (x.UserId == userId));
            if (isSub == null)
                throw new NotFound("Request");
            if (sub)
            {
                isSub.IsSubscribed = sub;
                await _context.SaveChangesAsync();
                return true;
            }
            else 
            {
                _context.Subscribers.Remove(isSub);
                await _context.SaveChangesAsync();
                return true;
            }
        }

        public async Task<bool> Subscribe(Guid subscriberId, Guid userId, bool sub)
        {
            var isSub = await _context.Subscribers.FirstOrDefaultAsync(x => (x.SubscriberId == subscriberId )&& (x.UserId == userId));
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null)
                throw new NotFound("user");
            if ((isSub == null) && (sub))
            {
                var postlike = await _context.Subscribers.AddAsync(new Subscriber
                {
                    UserId = userId,
                    SubscriberId = subscriberId,
                    IsSubscribed = user.IsOpen
                });
                await _context.SaveChangesAsync();
                return true;
            }
            else if ((isSub != null) && (!sub))
            {
                _context.Subscribers.Remove(isSub);
                await _context.SaveChangesAsync();
                return true;
            }
            else return false;
        }

        private async Task<UserModel> GetUserById(Guid id)
        {
            var user = await _context.Users.Where(x => x.Id == id).AsNoTracking().ProjectTo<UserModel>(_mapper.ConfigurationProvider).ToListAsync();
            if (user.IsNullOrEmpty())
                throw new NotFound("user");
            return user[0];
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}
