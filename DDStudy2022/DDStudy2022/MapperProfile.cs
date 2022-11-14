using Api.Models.Attach;
using Api.Models.Post;
using Api.Models.User;
using AutoMapper;
using Common;
using DAL.Entities;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace Api
{
    public class MapperProfile: Profile
    {
        public MapperProfile() {
            CreateMap<CreateUserModel, DAL.Entities.User>()
                .ForMember(d=>d.Id, m=>m.MapFrom(s=>Guid.NewGuid()))
                .ForMember(d=>d.PasswordHash, m=>m.MapFrom(s=>HashHelper.GetHash(s.Password)))
                .ForMember(d=>d.BirthDay, m=>m.MapFrom(s=>s.BirthDay.UtcDateTime))
                ;
            CreateMap<DAL.Entities.User, UserModel>();

            CreateMap<DAL.Entities.Avatar, AttachModel>();

            CreateMap<DAL.Entities.Attach, AttachModel>();

            CreateMap<DAL.Entities.UserPost, ShowPostModel>();

        }


    }
}
