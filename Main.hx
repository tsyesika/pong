import h2d.Text;
import h2d.Interactive;
import h2d.Graphics;

class Main extends hxd.App {
    var border: h2d.Graphics;
    var leftPlayerPaddle: h2d.Graphics;
    var rightPlayerPaddle: h2d.Graphics;
    var ball: h2d.Graphics;

    var gameStarted = false;
    var paddleSpeed = 30;
    var ballSpeed = 10;
    var ballDirection = 0;

    // scores
    var leftPlayerScore = 0;
    var rightPlayerScore = 0;
    var leftPlayerScoreText: h2d.Text;
    var rightPlayerScoreText: h2d.Text;

    override function init() {
        hxd.Window.getInstance().addEventTarget(onEvent);

        // Make the border of the game
        border = new h2d.Graphics(s2d);
        border.beginFill(0xCCCCCC);

        // We want to give it 25% padding
        // left side.
        var thickness = 5;
        border.drawRect(
            s2d.width * 0.25,
            s2d.height * 0.25,
            thickness,
            s2d.height * 0.5
        );
        // top.
        border.drawRect(
            s2d.width * 0.25 + thickness,
            s2d.height * 0.25,
            s2d.width * 0.5,
            thickness
        );
        // Right side.
        border.drawRect(
            s2d.width * 0.75,
            s2d.height * 0.25,
            thickness,
            s2d.height * 0.5
        );
        border.drawRect(
            s2d.width * 0.25,
            s2d.height * 0.75,
            s2d.width * 0.5 + thickness,
            thickness
        );
        border.endFill();

        // Add the paddels
        var paddleThickness = 100;
        leftPlayerPaddle = new Graphics(s2d);
        leftPlayerPaddle.beginFill(0xCCCCCC);
        leftPlayerPaddle.drawRect(
            (s2d.width * 0.26) + thickness + 10,
            s2d.height * 0.5 - (paddleThickness * 0.5), 
            thickness,
            100
        );
        leftPlayerPaddle.endFill();

        rightPlayerPaddle = new Graphics(s2d);
        rightPlayerPaddle.beginFill(0xCCCCCC);
        rightPlayerPaddle.drawRect(
            (s2d.width * 0.74) - thickness - 10,
            s2d.height * 0.5 - (paddleThickness * 0.5), 
            thickness,
            100
        );
        rightPlayerPaddle.endFill();

        // And draw the ball
        ball = new Graphics(s2d);
        ball.beginFill(0xCCCCCC);
        ball.drawCircle(s2d.width * 0.5, s2d.height * 0.5, 7.5);
        ball.endFill();

        // Add the scores.
        var font = hxd.res.DefaultFont.get();
        font.resizeTo(32);
        leftPlayerScoreText = new h2d.Text(font, s2d);
        rightPlayerScoreText = new h2d.Text(font, s2d);
        leftPlayerScoreText.text = "Score: 0";
        rightPlayerScoreText.text = "Score: 0";

        leftPlayerScoreText.x = s2d.width * 0.25 + 10;
        leftPlayerScoreText.y = s2d.height * 0.75 + 20;
        rightPlayerScoreText.x = s2d.width * 0.75 - 10 - rightPlayerScoreText.getBounds().xMax;
        rightPlayerScoreText.y = s2d.height * 0.75 + 20;

    }

    function onEvent(event: hxd.Event) {
        switch (event.keyCode) {
            // Arrow keys
            case 38: this.onKeyUp(rightPlayerPaddle, event);
            case 40: this.onKeyDown(rightPlayerPaddle, event);

            // WASD (actually only S and D)
            case 87: this.onKeyUp(leftPlayerPaddle, event);
            case 83: this.onKeyDown(leftPlayerPaddle, event);

            // Space to start.
            case 32: this.beginGame();
            case null:
            case _: trace("Unknown keycode:" + event.keyCode);
        }
    }

    override function update(_) {
        if (!this.gameStarted) {
            // Choose a random direction
            if (Math.random() < 0.5) {
                this.ballDirection =  -this.ballSpeed;
            } else {
                this.ballDirection = this.ballSpeed;
            }
            return;
        }

        // Move the ball!
        this.ball.x += this.ballDirection;

        // If it hits the paddle invert the direction;
        var ballBounds = this.ball.getBounds();
        if (this.leftPlayerPaddle.getBounds().intersects(ballBounds) ||
            this.rightPlayerPaddle.getBounds().intersects(ballBounds)) {
            this.ballDirection = -this.ballDirection;
        }

        var leftBorder = this.border.getBounds();
        leftBorder.xMax = leftBorder.xMin + 5;
        if (leftBorder.intersects(ballBounds)) {
            this.rightPlayerScore += 1;
            this.rightPlayerScoreText.text = "Score: " + this.rightPlayerScore;
            this.gameReset();
        }

        var rightBorder = this.border.getBounds();
        rightBorder.xMin = rightBorder.xMax - 5;
        if (rightBorder.intersects(ballBounds)) {
            leftPlayerScore += 1;
            this.leftPlayerScoreText.text = "Score: " + this.leftPlayerScore;
            this.gameReset();
        }

    }

    function gameReset() {
        this.gameStarted = false;
        this.ball.x = 0;
        this.ball.y = 0;
        this.ballDirection = 0;

        this.leftPlayerPaddle.y = 0;
        this.rightPlayerPaddle.y = 0;
    }

    function beginGame() {
        this.gameStarted = true;
    }

    function onKeyUp(obj: h2d.Graphics, event: hxd.Event):Void {
        // Ensure that it doesn't go outside the board.
        var borderTop = border.getBounds();
        borderTop.yMax = borderTop.yMin + paddleSpeed;
        if (obj.getBounds().intersects(borderTop)) {
            // Snap it to the border.
           obj.y -= obj.getBounds().y - borderTop.y;
        } else {
            obj.y -= paddleSpeed;
        }
    }
    function onKeyDown(obj: h2d.Graphics, event: hxd.Event):Void {
        // Ensure that it doesn't go outside the board.
        var borderBottom = border.getBounds();
        borderBottom.yMin = borderBottom.yMax - paddleSpeed;
        if (obj.getBounds().intersects(borderBottom)) {
            // Snap it to the border.
            obj.y += borderBottom.yMax - obj.getBounds().yMax;
        } else {
            obj.y += paddleSpeed;
        }
    }

    static function main() {
        hxd.Res.initEmbed();
        new Main();
    }
}