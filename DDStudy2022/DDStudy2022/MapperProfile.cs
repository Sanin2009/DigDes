using Api.Models;
using AutoMapper;
using Common;
using DAL.Entities;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace Api
{
    public class MapperProfile: Profile
    {
        public MapperProfile() {
            CreateMap<Models.CreateUserModel, DAL.Entities.User>()
                .ForMember(d=>d.Id, m=>m.MapFrom(s=>Guid.NewGuid()))
                .ForMember(d=>d.PasswordHash, m=>m.MapFrom(s=>HashHelper.GetHash(s.Password)))
                .ForMember(d=>d.BirthDay, m=>m.MapFrom(s=>s.BirthDay.UtcDateTime))
                ;
            CreateMap<DAL.Entities.User, Models.UserModel>();

            CreateMap<DAL.Entities.Avatar, Models.AttachModel>();

            CreateMap<DAL.Entities.Attach, Api.Models.AttachModel>();

            CreateMap<UserPost, AttachModel>();
        }


    }
}
