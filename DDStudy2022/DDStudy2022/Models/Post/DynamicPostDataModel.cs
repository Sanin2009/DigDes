namespace Api.Models.Post
{
    public class DynamicPostDataModel
    {
        public int TotalLikes { get; set; }
        public bool LikedByMe { get; set; }
        public int TotalComments { get; set; }
        public DynamicPostDataModel (int totalLikes, bool likedByMe, int totalComments)
        {
            TotalLikes = totalLikes;
            LikedByMe = likedByMe;
            TotalComments = totalComments;
        }
    }
}
