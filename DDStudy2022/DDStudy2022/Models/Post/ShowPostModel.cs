namespace Api.Models.Post
{
    public class ShowPostModel
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public DateTimeOffset Created { get; set; }
        public string Name { get; set; } = null!;
        public List<string>? Attaches { get; set; } = new List<string>();
        public int TotalLikes { get; set; }
        public bool LikedByMe { get; set; }
        public int TotalComments { get; set; }

        public ShowPostModel (Guid id, Guid userId, DateTimeOffset created, string name, List<string> attaches, int totalLikes, bool likedByMe, int totalComments)
        {
            Id = id;
            UserId = userId;
            Created = created;
            Name = name;
            Attaches = attaches;
            TotalLikes = totalLikes;
            LikedByMe = likedByMe;
            TotalComments = totalComments;
        }
    }
}
