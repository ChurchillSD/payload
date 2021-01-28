// Canvas infomation
const CANVAS_HEIGHT = 200;
const CANVAS_WIDTH = 700;

// Track config vars
const TRACK_START_POS = 75;
const TRACK_END_POS = 625;
const TRACK_Y_POS = 100;
const TRACK_THICKNESS = 5;
const TRACK_GLOW = 10;
const TRACK_LENGTH = TRACK_END_POS - TRACK_START_POS;

// Blue progress bar color
const ATTACKERS_PROGRESS_COLOR = "#5fabc8";
const ATTACKERS_PROGRESS_GLOW = "#007ffd";

// Red progress bar color
const DEFENDERS_PROGRESS_COLOR = "#e8c798";
const DEFENDERS_PROGRESS_GLOW = "#f89862"; 

// Payload config vars
const PAYLOAD_Y_OFFSET = 55
const PAYLOAD_START_POS = [TRACK_START_POS, PAYLOAD_Y_OFFSET]
const INDICATOR_ARROW_Y_OFFSET = 50
const INDICATOR_ARROW_X_OFFSET = 2

// Waypoint vars
const WAYPOINT_Y_OFFSET = 160;

// Payload ESP
ESP_IMG_MAX_SIZE = [60,60]
ESP_IMG_MIN_SIZE = [40,40]
ESP_MAX_DIST = 400