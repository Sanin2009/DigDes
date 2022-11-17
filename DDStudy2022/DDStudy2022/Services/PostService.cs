using Api.Configs;
using Api.Models.Attach;
using Api.Models.Comment;
using Api.Models.Post;
using Api.Models.User;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using Common;
using DAL;
using DAL.Entities;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace Api.Services
{
    public class PostService
    {
        private readonly IMapper _mapper;
        private readonly DAL.DataContext _context;

        public PostService(IMapper mapper, IOptions<AuthConfig> config, DataContext context)
        {
            _mapper = mapper;
            _context = context;
        }
        public async Task<UserPost> CreatePost(Guid userId, string Title)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null) throw new Exception("user not found");
            //var newpost = new UserPost { UserId=userId, Name=Title, Created=DateTimeOffset.Now};
            var newpost = await _context.UserPosts.AddAsync(new DAL.Entities.UserPost
            {
                UserId = userId,
                User = user,
                Name = Title,
                Created = DateTime.UtcNow,
                Id = Guid.NewGuid()
            });
            await _context.SaveChangesAsync();
            return newpost.Entity;
        }


        public async Task<Comment> AddComment(Guid userId, Guid postId, string msg)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
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
                Name = user.Name
            });
            await _context.SaveChangesAsync();
            return newcomment.Entity;
        }

        public async Task<List<ShowCommentModel>> ShowComments(Guid postId)
        {
            var t = await _context.Comments.Where(x => x.UserPostId == postId).AsNoTracking().ProjectTo<ShowCommentModel>(_mapper.ConfigurationProvider).ToListAsync();
            return t;
            //var result = new List<ShowCommentModel>();
            //foreach (var temp in t)
            //{
            //    var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == temp.UserId);
            //    if (user == null) break;
            //    var comment = new ShowCommentModel(temp.Id, user.Name, temp.Message, temp.Created, LinkHelper.Avatar(user.Id));
            //    result.Add(comment);
            //}
            //return result;
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

        public async Task<ShowPostModel> GetPostInfo(Guid postId)
        {
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => x.Id == postId);
            if (post == null) throw new Exception("Post not found");
            var attaches = await _context.PostImages.Where(x => x.UserPostId == postId).ToListAsync();
            var attachLinks = new List<string>();
            foreach (var attachment in attaches)
            {
                attachLinks.Add(LinkHelper.Attach(attachment.Id));
            }
            var result = new ShowPostModel(post.Id, post.UserId, post.Created, post.Name, attachLinks);
            return result;
            //return await _context.PostImages.Include(x => x.UserPost).Where(x =>x.UserPostId == postId).AsNoTracking().ProjectTo<AttachModel>(_mapper.ConfigurationProvider).ToListAsync(); //. Aggregate(x => x.Id == postId);
        }

        public async Task<ShowFullPostModel> GetPost(Guid postId)
        {
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => x.Id == postId);
            if (post == null) throw new Exception("Post not found");
            var t1 = await GetPostInfo(postId);
            var t2 = await GetUser(post.UserId);
            var t3 = await ShowComments(postId);
            return new ShowFullPostModel(t1, t2, t3);
        }

        public async Task<UserModel> GetUser(Guid id)
        {
            var user = await GetUserById(id);
            return _mapper.Map<UserModel>(user);

        }

        public async Task<List<ShowFullPostModel>> GetAllPosts(int skip, int take)
        {
            var temp = await _context.UserPosts.OrderByDescending(x => x.Created).Skip(skip).Take(take).ToListAsync();
            var result = new List<ShowFullPostModel>();
            foreach (UserPost u in temp)
            {
                var t = await GetPost(u.Id);
                result.Add(t);
            }
            return result;
        }

        public async Task<AttachModel> GetAttach(Guid attachId)
        {
            var attachT = await _context.Attaches.FirstOrDefaultAsync(x => x.Id == attachId);
            //var user = await GetUserById(userId);
            var attach = _mapper.Map<AttachModel>(attachT);
            if (attach == null) throw new Exception("attach not found");
            return attach;
        }
        private async Task<DAL.Entities.User> GetUserById(Guid id)
        {
            var user = await _context.Users.Include(x => x.Avatar).FirstOrDefaultAsync(x => x.Id == id);
            if (user == null)
                throw new Exception("user not found");
            return user;
        }

    }
}
