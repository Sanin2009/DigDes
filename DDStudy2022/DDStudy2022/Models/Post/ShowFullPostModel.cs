using Api.Models.Comment;
using Api.Models.User;

namespace Api.Models.Post
{
    public class ShowFullPostModel
    {
        public ShowPostModel ShowPostModel { get; set; } = null!;
        public UserModel UserModel { get; set; } = null!;
        public List<ShowCommentModel>? showCommentModels { get; set; }

        public ShowFullPostModel (ShowPostModel showPostModel, UserModel userModel, List<ShowCommentModel>? showCommentModels)
        {
            ShowPostModel = showPostModel;
            UserModel = userModel;
            this.showCommentModels = showCommentModels;
        }
    }
}
