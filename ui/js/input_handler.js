// Globals
previous_distance_moved = 0

window.init_UI = function(data)
{
    team_name = data.team_name

    // Add up all distances 
    var total_dist = sum_array(data.waypoint_distances)

    // Length of payload track on UI
    dist_per_pixel = total_dist/TRACK_LENGTH 

    // Get waypoint positions on UI
    get_waypoint_positions(data.cp_waypoint_numbers, data.waypoint_distances, dist_per_pixel)

    // Set up track
    static_ctx.moveTo(TRACK_START_POS, TRACK_Y_POS);
    static_ctx.lineTo(TRACK_END_POS, TRACK_Y_POS);
    static_ctx.strokeStyle = "#FFFFFF";
    static_ctx.lineWidth = TRACK_THICKNESS;
    static_ctx.lineCap = 'round';
    static_ctx.shadowBlur = TRACK_GLOW;
    static_ctx.shadowColor = "#73b7ff";
    static_ctx.stroke();

    clear_canvas(dynamic_ctx);
    // Inital pos of payload
    draw_payload(PAYLOAD_START_POS, dynamic_ctx)
};

window.update_ESP = function(data){
    payload_screen_pos = [data.payload_x, data.payload_y]
    dist_to_payload = data.dist_to_payload

    draw_payload_esp(payload_screen_pos, dist_to_payload)
}

window.update_UI = function(data)
{                
    team_name = data.team_name
    time_left = data.time_left
    
    // Check if payload moving backwards
    var payload_moving_backwards = false
    if (data.dist_moved < previous_distance_moved){
        payload_moving_backwards = true;
    }
    previous_distance_moved = data.dist_moved;

    // Update the payload position on UI using total distance moved
    if(dist_per_pixel != null){
        payload_pos[0] = (data.dist_moved/dist_per_pixel) + TRACK_START_POS; //Offset
    }

    // Clear the dynamic canvas
    clear_canvas(dynamic_ctx)

    // Update dynamic canvas elements
    draw_waypoints(payload_pos, dynamic_ctx)
    update_pushing_status(payload_pos, data.payload_blocked, payload_moving_backwards, data.attckers_pushing, dynamic_ctx)
    update_track(payload_pos, dynamic_ctx)
    draw_payload(payload_pos, dynamic_ctx, data.payload_blocked, data.attckers_pushing, payload_moving_backwards)


    // Update time left
    if (typeof time_left !== "undefined"){
        var minutes = Math.floor(time_left.toFixed(0) / 60);
        var seconds = time_left.toFixed(0) - minutes * 60;
        var time_left_str = "Time Left: "
        if (minutes > 0){
            time_left_str = time_left_str + minutes.toString() + "m ";
        } 
        time_left_str = time_left_str + seconds.toString() + "s"
        document.getElementById("time_left").innerText =  time_left_str;
    } else {
        document.getElementById("time_left").innerText =  '';
    }
};