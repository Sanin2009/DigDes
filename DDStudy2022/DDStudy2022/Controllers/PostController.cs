using Api.Consts;
using Api.Models.Attach;
using Api.Models.Comment;
using Api.Models.Post;
using Api.Services;
using Common;
using Common.Extentions;
using DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration.UserSecrets;

namespace Api.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class PostController : ControllerBase
    {
        private readonly UserService _userService;
        private readonly PostService _postService;

        public PostController(UserService userService, PostService postService)
        {
            _userService = userService;
            _postService = postService;
        }

        [HttpPost]
        [Authorize]
        public async Task CreatePost(CreatePostModel createPostModel)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            if (userId!=default)
            {
                var post = await _postService.CreatePost(userId, createPostModel.Title, createPostModel.Tags);
                foreach (MetadataModel model in createPostModel.Metadata)
                {
                    var tempFi = new FileInfo(Path.Combine(Path.GetTempPath(), model.TempId.ToString()));
                    if (!tempFi.Exists)
                        throw new Exception("file not found");
                    else
                    {
                        var path = Path.Combine(Directory.GetCurrentDirectory(), "attaches", model.TempId.ToString());
                        var destFi = new FileInfo(path);
                        if (destFi.Directory != null && !destFi.Directory.Exists)
                            destFi.Directory.Create();

                        System.IO.File.Copy(tempFi.FullName, path, true);
                        await _postService.AddImageToPost(userId, post, model, path);
                    }
                }
            }
        }

        [HttpPost]
        [Authorize]
        public async Task<Comment> AddComment(Guid postId, string msg)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _postService.AddComment(userId, postId, msg);
        }

        [HttpPost]
        [Authorize]
        public async Task<List<ShowCommentModel>> ShowComments(Guid postId)
        {
            return await _postService.ShowComments(postId);
        }

        [HttpGet]
        [Authorize]
        public async Task<List<ShowScrollPostModel>> GetAllPosts(int skip = 0, int take = 10)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _postService.GetAllPosts(skip, take, userId);
        }

        [HttpGet]
        [Authorize]
        public async Task<List<ShowScrollPostModel>> GetUsersPosts(Guid userId, int skip = 0, int take = 10)
        {
            var subscriberId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _postService.GetUsersPosts(skip, take, subscriberId, userId);
        }

        [HttpGet]
        [Authorize]
        public async Task<List<ShowScrollPostModel>> GetPostsByTag(string inputTag, int skip = 0, int take = 10)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _postService.GetPostsByTag(skip, take, userId, inputTag);
        }

        [HttpGet]
        [Authorize]
        public async Task<ShowFullPostModel> GetPost(Guid postId)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _postService.GetFullPost(postId, userId);
        }

        [HttpPut]
        [Authorize]
        public async Task<bool> UpdateLike(Guid postId)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _postService.UpdateLike(postId, userId);
        }

        [HttpPut]
        [Authorize]
        public async Task<Comment> EditComment(Guid commentId, string msg)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            return await _postService.EditComment(userId, commentId, msg);
        }

        [HttpDelete]
        [Authorize]
        public async Task DeletePost(Guid postId)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            await _postService.DeletePost(userId, postId);
        }

        [HttpDelete]
        [Authorize]
        public async Task DeleteComment(Guid commentId)
        {
            var userId = User.GetClaimValue<Guid>(ClaimNames.Id);
            await _postService.DeleteComment(userId, commentId);
        }

    }
}
