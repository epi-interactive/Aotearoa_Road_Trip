

var updateCarPosition = function(init, latlng, speed, direction) {
    
    if(init) {
        
        carIcon = L.icon({
            iconUrl: 'img/CarGif_downsized_left.gif', iconSize: [60, 40], iconAnchor: [30, 20]
        });
        car = L.Marker.movingMarker([latlng]);
        car.options.icon = carIcon;
        car.options.zIndexOffset = 1000;
        car.options.interactive = false;
        
        car.on('start', function() {
            links = $('.map-control-link');
            links.each(function(idx) {
                $( this ).addClass('disabled')   
            });
        })
        
        car.on('end', function() {
            var element = document.getElementById("scrollLocator");
            element.scrollIntoView({behavior: "smooth", block: "end", inline: "end"});
            
            links = $('.map-control-link');
            links.each(function(idx) {
                $( this ).removeClass('disabled')   
            });
        })
        
        car.addTo(map);
    }
    else {
        car._icon.src = ("img/CarGif_downsized_" + direction + ".gif");
        
        coords = L.latLng(latlng[0], latlng[1]);
        
        car.moveTo(latlng, speed);
        map.panTo(coords, options = {duration: speed/1000});
    }
}