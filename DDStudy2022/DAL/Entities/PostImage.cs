
namespace DAL.Entities
{
    public class PostImage : Attach
    {
        public virtual UserPost UserPost { get; set; } = null!;
        public Guid UserPostId { get; set; }    
    }
}
