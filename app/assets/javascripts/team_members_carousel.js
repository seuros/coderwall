$('.flexslider').flexslider({
    animation: "slide",
    animationLoop: true,
    itemWidth: 210,
    itemMargin: 5
});

var first_member_thumb_slide=  $("#team_members_carousel .member_thumb_slide").first();
var first_member_thumb_details= first_member_thumb_slide.find(".member_thumb_details");
$("#member_thumb_expanded").html(first_member_thumb_details.html());

$("#team_members_carousel .member_thumb_slide").click(function(){
    var  member_thumb_details=$(this).find(".member_thumb_details");
    $("#member_thumb_expanded").html(member_thumb_details.html() );
});
