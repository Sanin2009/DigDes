using Api.Models.Attach;
using Api.Models.Comment;
using Api.Models.Post;
using Api.Services;
using Common;
using DAL.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers
{
    [Route("api/[controller]/[action]")]
    [ApiController]
    public class PostController : ControllerBase
    {
        private readonly UserService _userService;

        public PostController(UserService userService)
        {
            _userService = userService;
        }

        [HttpGet]
        public async Task<List<ShowFullPostModel>> GetIdPosts(int skip=0, int take=10)
        {
            return await _userService.GetIdPosts(skip,take);
        }

        [HttpPost]
        [Authorize]
        public async Task CreatePost(CreatePostModel createPostModel)
        {
            var userIdString = User.Claims.FirstOrDefault(x => x.Type == "id")?.Value;
            if (Guid.TryParse(userIdString, out var userId))
            {
                var post = await _userService.CreatePost(userId, createPostModel.Title);
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
                        await _userService.AddImageToPost(userId, post, model, path);
                    }
                }

            }
        }

        [HttpPost]
        [Authorize]
        public async Task AddComment(Guid postId, string msg)
        {
            var userIdString = User.Claims.FirstOrDefault(x => x.Type == "id")?.Value;
            if (userIdString == null) throw new Exception("id not found");
            await _userService.AddComment(userIdString, postId, msg);
        }

        [HttpPost]
        public async Task<List<ShowCommentModel>> ShowComments(Guid postId)
        {
            return await _userService.ShowComments(postId);
        }

        [HttpGet]
        public async Task<ShowFullPostModel> GetPost(Guid postId)
        {
            return await _userService.GetPost(postId);
            //var result = new List<string>();

            //foreach (AttachModel model in image)
            //{
            //    result.Add(LinkHelper.Attach(model.Id));
            //    //var t = model.Id;
            //    //var urlString = "https://localhost:7191" + "/api/User/GetAttach?attachId=" + t.ToString();
            //    //result.Add(urlString);
            //}
            //return result;
        }



    }
}
