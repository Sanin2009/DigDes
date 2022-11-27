using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.Entities
{
    public class Subscriber
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public Guid SubscriberId { get; set; }
        public bool IsSubscribed { get; set; }
        public virtual User Users { get; set; } = null!;
    }
}
