using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Common
{
    public class NotFound : Exception
    {
        public string? Input { get; set; }
        public NotFound (string input)
        {
            Input = input; 
        }
        public override string Message => $"{Input} not found";
    }
    public class BadRequest : Exception
    {
        public override string Message => "Bad input";
    }
    public class NoAccess : Exception
    {
        public override string Message => "No access";
    }
}
