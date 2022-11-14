using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public static class LinkHelper
    {
        public static string Attach (Guid attachId)
        {
            return "/api/Attach/GetAttach?attachId=" + attachId.ToString();
        }
        
        public static string Avatar (Guid userId)
        {
            return "/api/Attach/GetUserAvatar?userId=" + userId.ToString();
        }
    }
}
