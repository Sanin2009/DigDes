using Api.Models.Comment;
using Api.Models.User;

namespace Api.Models.Post
{
    public class ShowScrollPostModel
    {
        public ShowPostModel ShowPostModel { get; set; } = null!;
        public UserModel UserModel { get; set; } = null!;
        public ShowScrollPostModel (ShowPostModel showPostModel, UserModel userModel)
        {
            ShowPostModel = showPostModel;
            UserModel = userModel;
        }
    }
    public class ShowFullPostModel
    {
        public ShowPostModel ShowPostModel { get; set; } = null!;
        public UserModel UserModel { get; set; } = null!;
        public List<ShowCommentModel>? ShowCommentModels { get; set; }

        public ShowFullPostModel (ShowPostModel showPostModel, UserModel userModel, List<ShowCommentModel>? showCommentModels)
        {
            ShowPostModel = showPostModel;
            UserModel = userModel;
            ShowCommentModels = showCommentModels;
        }
    }
}
