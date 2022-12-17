using Api.Configs;
using Api.Migrations;
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
using Microsoft.EntityFrameworkCore.Internal;
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
        public async Task<UserPost> CreatePost(Guid userId, string title, string? tags)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null) throw new NotFound("user");
            var newpost = await _context.UserPosts.AddAsync(new DAL.Entities.UserPost
            {
                UserId = userId,
                User = user,
                Name = title,
                Created = DateTime.UtcNow,
                Id = Guid.NewGuid(),
                TagString = tags ?? " "                
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
            return await _context.Comments.Where(x => x.UserPostId == postId).OrderBy(x=>x.Created).AsNoTracking().ProjectTo<ShowCommentModel>(_mapper.ConfigurationProvider).ToListAsync();
        }

        public async Task DeleteComment(Guid userId, Guid commentId)
        {
            var comment = await _context.Comments.FirstOrDefaultAsync(x => (x.Id == commentId) && x.UserId == userId); 
            if (comment==null) throw new NoAccess();
            _context.Remove(comment);
            await _context.SaveChangesAsync();
        }
        public async Task DeletePost(Guid userId, Guid postId)
        {
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => (x.Id == postId) && (x.UserId == userId)); 
            if (post==null) throw new NoAccess();
            _context.UserPosts.Remove(post);
            await _context.SaveChangesAsync();
        }

        public async Task<Comment> EditComment(Guid userId, Guid commentId, string msg)
        {
            var comment = await _context.Comments.Where(x => (x.Id == commentId) && (x.UserId == userId)).ToListAsync();
            if (comment.IsNullOrEmpty()) throw new NoAccess();
            comment[0].Message = msg;
            await _context.SaveChangesAsync();
            return comment[0];
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
                Size = model.Size,
                Created = DateTimeOffset.Now,
            });
            await _context.SaveChangesAsync();
        }

        public async Task<ShowPostModel> GetPostInfo(UserPost post, Guid userId)
        {
            if (post == null) throw new NotFound("Post");
            var attaches = await _context.PostImages.Where(x => x.UserPostId == post.Id).ToListAsync();
            var attachLinks = new List<string>();
            foreach (var attachment in attaches)
            {
                attachLinks.Add(LinkHelper.Attach(attachment.Id));
            }
            var isLiked = await _context.PostLikes.AnyAsync(x => x.UserPostId == post.Id && x.UserId == userId);
            int likes = _context.PostLikes.Where(x => x.UserPostId == post.Id).Count();
            int comments = _context.Comments.Where(x => x.UserPostId == post.Id).Count();
            var result = new ShowPostModel(post.Id, post.UserId, post.Created, post.Name, attachLinks, likes, isLiked, comments);
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
        public async Task<ShowFullPostModel> GetFullPost(Guid postId, Guid userId)
        {
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => x.Id == postId);
            if (post == null) throw new NotFound("Post");
            var t1 = await GetPostInfo(post, userId);
            var t2 = await GetUser(post.UserId);
            var t3 = await ShowComments(postId);
            return new ShowFullPostModel(t1, t2, t3);
        }

        public async Task<ShowScrollPostModel> GetPost(Guid postId, Guid userId)
        {
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => x.Id == postId);
            if (post == null) throw new NotFound("Post");
            var t1 = await GetPostInfo(post, userId);
            var t2 = await GetUser(post.UserId);
            return new ShowScrollPostModel(t1, t2);
        }

        public async Task<UserModel> GetUser(Guid id)
        {
            return await GetUserById(id);
        }

        public async Task<List<ShowScrollPostModel>> GetFeed(Guid userId, int skip=0, int take=10)
        {
            var temp = await _context.Subscribers.Where(x => (x.SubscriberId == userId) && (x.IsSubscribed == true))
                .Include(x => x.Users).ThenInclude(u=>u.UserPosts)
                .SelectMany(p=>p.Users.UserPosts).OrderByDescending(x=>x.Created)
                .Skip(skip).Take(take).AsNoTracking().ToListAsync();
            var result = new List<ShowScrollPostModel>();
            foreach (UserPost p in temp)
            {
                var t = await GetPost(p.Id, userId);
                result.Add(t);
            }
            return result;
        }


        public async Task<List<ShowScrollPostModel>> GetAllPosts(Guid userId, int skip = 0, int take = 10)
        {
            var temp = await _context.UserPosts.OrderByDescending(x => x.Created).Skip(skip).Take(take).ToListAsync();
            var result = new List<ShowScrollPostModel>();
            foreach (UserPost p in temp)
            {
                var t = await GetPost(p.Id, userId);
                result.Add(t);
            }
            return result;
        }

        public async Task<List<ShowScrollPostModel>> GetUsersPosts(int skip, int take, Guid subscriberId, Guid userId)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            if (user == null)
                throw new NotFound("user");
            var sub = await _context.Subscribers.AnyAsync(x=>(x.SubscriberId == subscriberId) && (x.UserId == userId) && (x.IsSubscribed));
            if ((userId==subscriberId) || (user.IsOpen) || (sub))
            {
                var temp = await _context.UserPosts.OrderByDescending(x => x.Created).Where(x=>x.UserId == userId).Skip(skip).Take(take).ToListAsync();
                var result = new List<ShowScrollPostModel>();
                foreach (UserPost p in temp)
                {
                    var t = await GetPost(p.Id, subscriberId);
                    result.Add(t);
                }
            return result;
            }
            else return new List<ShowScrollPostModel>();
        }

        public async Task<List<ShowScrollPostModel>> GetPostsByTag(int skip, int take, Guid userId, string inputTag)
        {
            var temp = await _context.UserPosts.Where(x=>x.TagString.ToLower().Contains(inputTag.ToLower())).OrderByDescending(x => x.Created).Skip(skip).Take(take).ToListAsync();
            var result = new List<ShowScrollPostModel>();
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
        private async Task<UserModel> GetUserById(Guid id)
        {
            var user = await _context.Users.Where(x=>x.Id==id).AsNoTracking().ProjectTo<UserModel>(_mapper.ConfigurationProvider).ToListAsync();
            if (user.IsNullOrEmpty())
                throw new NotFound("user");
            return user[0];
        }

    }
}
