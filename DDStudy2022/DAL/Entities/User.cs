using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.Entities
{
    public class User
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = "empty";
        public string Email { get; set; } = "empty";
        public string PasswordHash { get; set; } = "empty"; 
        public DateTimeOffset BirthDay { get; set; }
        public DateTimeOffset LastActive { get; set; } = DateTimeOffset.UtcNow;
        public bool IsOpen { get; set; } = true;
        public bool IsActive { get; set; } = true;
        public string? Status { get; set; }
        public virtual ICollection<Avatar>? Avatar { get; set; }
        public virtual ICollection<UserSession>? Sessions { get; set; }
        public virtual ICollection<Comment>? Comments { get; set; }   
        public virtual ICollection<UserPost>? UserPosts { get; set; }
        public virtual ICollection<PostLike>? PostLikes { get; set; }
        public virtual ICollection<Subscriber>? Subscribers { get; set; }


    }
}
