
namespace DAL.Entities
{
    public class PostImage : Attach
    {
        public virtual User User { get; set; } = null!;
        public Guid UserId { get; set; }
        public virtual UserPost UserPost { get; set; } = null!;
        public Guid UserPostId { get; set; }    
    }
}
