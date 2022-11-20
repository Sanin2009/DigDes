using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.Entities
{
    public class Subscriber
    {
        public Guid SubscriberId { get; set; }
        public Guid UserId { get; set; }
        public bool IsSubscribed { get; set; }
        public virtual ICollection<User> Users { get; set; } = null!;
    }
}
