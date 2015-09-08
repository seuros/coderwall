var  map;
$(function () {
    map = new google.maps.Map(document.getElementById('location-map'), {
        zoom: 11
    });

    positionOnAddress($(".location-details .selected .address").text());

    $("ul.locations li.team_location .address").click(function(){
        positionOnAddress($(this).text());
    });
});

function positionOnAddress(address){
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode({'address': address}, function(results, status) {
        if (status === google.maps.GeocoderStatus.OK) {
            map.setCenter(results[0].geometry.location);
            var marker = new google.maps.Marker({
                map: map,
                position: results[0].geometry.location
            });
        } else {
            console.log('Geocode was not successful for the following reason: ' + status);
        }
    });
}