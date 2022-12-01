using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.Entities
{
    public class PostLike
    {
        public Guid UserPostId { get; set; }
        public Guid UserId  { get; set; }
        public virtual User Users { get; set; } = null!;
        public virtual UserPost UserPosts { get; set; } = null!;
    }
}
