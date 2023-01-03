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
using Microsoft.Extensions.Hosting;
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
                Created = DateTimeOffset.UtcNow,
                Id = Guid.NewGuid(),
                TagString = tags ?? " "                
            });
            await _context.SaveChangesAsync();
            return newpost.Entity;
        }

        public async Task AddComment(Guid userId, Guid postId, string msg)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Id == userId);
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => x.Id == postId);
            if (user == null) throw new NotFound("user");
            if (post == null) throw new NotFound("post");
            var newcomment = await _context.Comments.AddAsync(new DAL.Entities.Comment
            {
                User = user,
                UserPost = post,
                Created = DateTimeOffset.UtcNow,
                Id = Guid.NewGuid(),
                Message = msg,
                Name = user.Name
            });
            await _context.SaveChangesAsync();
        }

        public async Task<List<ShowCommentModel>> ShowComments(Guid postId)
        {
            return await _context.Comments.Where(x => x.UserPostId == postId).OrderBy(x=>x.Created).AsNoTracking().ProjectTo<ShowCommentModel>(_mapper.ConfigurationProvider).ToListAsync();
        }

        public async Task DeleteComment(Guid userId, Guid commentId)
        {
            var comment = await _context.Comments.FirstOrDefaultAsync(x => x.Id == commentId);
            if (comment == null) throw new NoAccess();
            var post = await _context.UserPosts.FirstOrDefaultAsync(x => x.Id == comment.UserPostId);
            if (post == null) throw new NoAccess();
            if ((post.UserId!=userId) && (comment.UserId!=userId)) throw new NoAccess();
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
                Size = model.Size,
                Created = DateTimeOffset.UtcNow,
            });
            await _context.SaveChangesAsync();
        }

        public async Task<ShowPostModel> GetPostInfo(UserPost post, Guid userId)
        {
            if (post == null) throw new NotFound("Post");
            var attachLinks = new List<string>();
            foreach (var attachment in post.PostImages)
            {
                attachLinks.Add(LinkHelper.Attach(attachment.Id));
            }
            var isLiked = await _context.PostLikes.AnyAsync(x => x.UserPostId == post.Id && x.UserId == userId);
            int likes = _context.PostLikes.Where(x => x.UserPostId == post.Id).Count();
            int comments = _context.Comments.Where(x => x.UserPostId == post.Id).Count();
            var result = new ShowPostModel(post.Id, post.UserId, post.Created, post.Name, attachLinks, likes, isLiked, comments);
            return result;
        }

        public async Task<DynamicPostDataModel> GetDynamicPostData (Guid postId, Guid userId)
        {
            var isLiked = await _context.PostLikes.AnyAsync(x => x.UserPostId == postId && x.UserId == userId);
            int likes = _context.PostLikes.Where(x => x.UserPostId == postId).Count();
            int comments = _context.Comments.Where(x => x.UserPostId == postId).Count();
            return new DynamicPostDataModel(likes, isLiked, comments);
        }

        public async Task UpdateLike(Guid postId, Guid userId)
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
            }
            else 
            {
                _context.PostLikes.Remove(isLiked);
                await _context.SaveChangesAsync();
            }
        }
        public async Task<ShowFullPostModel> GetFullPost(Guid postId, Guid userId)
        {
            var post = await _context.UserPosts.Include(x => x.User).Include(x => x.PostImages).FirstOrDefaultAsync(x => x.Id == postId);
            if (post == null) throw new NotFound("Post");
            var t1 = await GetPostInfo(post, userId);
            var t2 = await GetUserById(post.UserId);
            var t3 = await ShowComments(postId);
            return new ShowFullPostModel(t1, t2, t3);
        }

        public async Task<ShowScrollPostModel> GetPost(UserPost post, Guid userId)
        {
            if (post == null) throw new NotFound("Post");
            var t1 = await GetPostInfo(post, userId);
            var t2 = _mapper.Map<UserModel>(post.User);
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
                .SelectMany(p=>p.Users.UserPosts).Include(x=>x.User).Include(x=>x.PostImages).OrderByDescending(x=>x.Created)
                .Skip(skip).Take(take).AsNoTracking().ToListAsync();
            var result = new List<ShowScrollPostModel>();
            foreach (UserPost p in temp)
            {
                var t = await GetPost(p, userId);
                result.Add(t);
            }
            return result;
        }

        public async Task<List<ShowScrollPostModel>> GetAllPosts(Guid userId, int skip = 0, int take = 10)
        {
            var temp = await _context.Users.Where(x => x.IsOpen == true).Include(x => x.UserPosts).SelectMany(x => x.UserPosts)
                .Include(x => x.User).Include(x => x.PostImages).OrderByDescending(x => x.Created).Skip(skip).Take(take).ToListAsync();
            var result = new List<ShowScrollPostModel>();
            foreach (UserPost p in temp)
            {
                var t = await GetPost(p, userId);
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
                var temp = await _context.UserPosts.Include(x => x.User).Include(x => x.PostImages).OrderByDescending(x => x.Created).Where(x=>x.UserId == userId).Skip(skip).Take(take).ToListAsync();
                var result = new List<ShowScrollPostModel>();
                foreach (UserPost p in temp)
                {
                    var t = await GetPost(p, subscriberId);
                    result.Add(t);
                }
            return result;
            }
            else return new List<ShowScrollPostModel>();
        }

        public async Task<List<ShowScrollPostModel>> GetPostsByTag(int skip, int take, Guid userId, string inputTag)
        {
            var temp = await _context.Users.Where(x=>x.IsOpen==true).Include(x=>x.UserPosts).SelectMany(x=>x.UserPosts)
                .Include(x => x.User).Include(x => x.PostImages).Where(x=>x.TagString.ToLower().Contains(inputTag.ToLower())).OrderByDescending(x => x.Created).Skip(skip).Take(take).ToListAsync();
            var result = new List<ShowScrollPostModel>();
            foreach (UserPost p in temp)
            {
                var t = await GetPost(p, userId);
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
        public void Dispose()
        {
            _context.Dispose();
        }

    }
}
