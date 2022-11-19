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
using Microsoft.IdentityModel.Tokens;

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
            if (user == null) throw new NotFound("user");
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
            if (user == null) throw new NotFound("user");
            if (post == null) throw new NotFound("post");
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
            return await _context.Comments.Where(x => x.UserPostId == postId).AsNoTracking().ProjectTo<ShowCommentModel>(_mapper.ConfigurationProvider).ToListAsync();
        }

        public async Task DeleteComment(Guid userId, Guid commentId)
        {
            var comment = await _context.Comments.FirstOrDefaultAsync(x => (x.Id == commentId) && (x.UserId == userId)); //.ToListAsync();
            if (comment==null) throw new NoAccess();
            _context.Remove(comment);
            await _context.SaveChangesAsync();
        }
        public async Task DeletePost(Guid userId, Guid postId)
        {
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => (x.Id == postId) && (x.UserId == userId)); //.ToListAsync();
            if (post==null) throw new NoAccess();
            _context.UserPosts.Remove(post);
            await _context.SaveChangesAsync();
        }

        public async Task EditComment(Guid userId, Guid commentId, string msg)
        {
            var comment = await _context.Comments.Where(x => (x.Id == commentId) && (x.UserId == userId)).ToListAsync();
            if (comment.IsNullOrEmpty()) throw new NoAccess();
            comment[0].Message = msg;
            await _context.SaveChangesAsync();
        }

        public async Task AddImageToPost(Guid userId, UserPost postId, MetadataModel model, string filepath)
        {
            var user = await _context.Users.Include(x => x.Avatar).FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null) throw new NotFound("user");
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

        public async Task<ShowPostModel> GetPostInfo(Guid postId, Guid userId)
        {
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => x.Id == postId);
            if (post == null) throw new NotFound("post");
            var attaches = await _context.PostImages.Where(x => x.UserPostId == postId).ToListAsync();
            var attachLinks = new List<string>();
            foreach (var attachment in attaches)
            {
                attachLinks.Add(LinkHelper.Attach(attachment.Id));
            }
            var isLiked = await _context.PostLikes.AnyAsync(x => x.UserPostId == postId && x.UserId == userId);
            int likes = _context.PostLikes.Where(x=>x.UserPostId==postId).Count();
            var result = new ShowPostModel(post.Id, post.UserId, post.Created, post.Name, attachLinks, likes, isLiked);
            return result;
        }

        public async Task<bool> UpdateLike(Guid postId, Guid userId)
        {
            var isLiked = await _context.PostLikes.FirstOrDefaultAsync(x => x.UserPostId == postId && x.UserId == userId);
            if (isLiked==null)
            {
                var postlike = await _context.PostLikes.AddAsync(new PostLike
                {
                    UserId = userId,
                    UserPostId = postId
                });
                await _context.SaveChangesAsync();
                return true;
            }
            else 
            {
                _context.PostLikes.Remove(isLiked);
                await _context.SaveChangesAsync();
                return false;
            }
        }

        public async Task<ShowFullPostModel> GetPost(Guid postId, Guid userId)
        {
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => x.Id == postId);
            if (post == null) throw new NotFound("post");
            var t1 = await GetPostInfo(postId, userId);
            var t2 = await GetUser(post.UserId);
            var t3 = await ShowComments(postId);
            return new ShowFullPostModel(t1, t2, t3);
        }

        public async Task<UserModel> GetUser(Guid id)
        {
            var user = await GetUserById(id);
            return _mapper.Map<UserModel>(user);

        }

        public async Task<List<ShowFullPostModel>> GetAllPosts(int skip, int take, Guid userId)
        {
            var temp = await _context.UserPosts.OrderByDescending(x => x.Created).Skip(skip).Take(take).ToListAsync();
            var result = new List<ShowFullPostModel>();
            foreach (UserPost p in temp)
            {
                var t = await GetPost(p.Id, userId);
                result.Add(t);
            }
            return result;
        }

        public async Task<AttachModel> GetAttach(Guid attachId)
        {
            var attachT = await _context.Attaches.FirstOrDefaultAsync(x => x.Id == attachId);
            var attach = _mapper.Map<AttachModel>(attachT);
            if (attach == null) throw new NotFound("attach");
            return attach;
        }
        private async Task<DAL.Entities.User> GetUserById(Guid id)
        {
            var user = await _context.Users.Include(x => x.Avatar).FirstOrDefaultAsync(x => x.Id == id);
            if (user == null)
                throw new NotFound("user");
            return user;
        }

    }
}
