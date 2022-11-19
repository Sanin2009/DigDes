
namespace DAL.Entities
{
    public class UserPost
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public DateTimeOffset Created { get; set; }
        public string Name { get; set; } = null!;
        public bool IsActive { get; set; } = true;
        public string TagString { get; set; } = null!;
        public virtual ICollection<PostImage>? PostImages { get; set; }
        public virtual User User { get; set; } = null!;
        public virtual ICollection<Comment>? Comments { get; set; }
        public virtual ICollection<PostLike>? PostLikes { get; set; }

    }
}
