//= require jquery
//= require jquery_ujs
//= require materialize-sprockets
//= require jquery.flexslider-min
//= require jquery_nested_form
//= require jquery.remotipart

$(function () {
    $(".button-collapse").sideNav();

    $(".dropdown-button").dropdown();

    $(".button_to_toggle").click(function(){
        $(this).parent().find('.content_to_toggle').slideToggle();
    });

    Chute.setApp('502d8ffd3f59d8200c000097');//https://github.com/chute/media-chooser

    $("ul.edit-photos").on( "click","a.remove-photo", function(e) {
        e.preventDefault();
        return $(this).parent('li.preview-photos').remove();
    });

    $("a.photos-chooser").click(function(e) {
        var width;
        e.preventDefault();
        width = $(this).attr("data-fit-w");
        return Chute.MediaChooser.choose(function(urls, data) {
            var i, results, url;
            i = 0;
            results = [];
            while (i < urls.length) {
                url = Chute.width(width, urls[i]);
                setTimeout((function() {
                    return Chute.width(width, urls[i]);
                }), 1000);
                setTimeout((function() {
                    return Chute.width(width, urls[i]);
                }), 5000);
                $("ul.edit-photos").append("<li class=' col s3 preview-photos'> <a href='#' class='remove-photo red-text'>Remove</a><img src='" + url + "'/> <input type='hidden' name='team[office_photos][]' value='" + url + "' /> </li>");
                results.push(i++);
            }
            return results;
        });
    });


    $('a.add-interview-step').click(function(e) {
        e.preventDefault();
        return $("ul.edit-interview-steps").append("<li class='interview-step'> <div class='col s12 input-field'> <textarea name='team[interview_steps][]' class='materialize-textarea'></textarea> </div> <a class='remove-interview-step red-text' href='#'>Remove</a> </li>");
    });

    $('a.remove-interview-step').click(function(e) {
        e.preventDefault();
        return $(this).parents('li.interview-step').remove();
    });
});
