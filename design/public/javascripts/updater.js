if (typeof RT == "undefined") RT = {};

RT.delay = 60;

RT.Updater = Class.create({
  initialize: function() {
    this.form = $('vote').down('form');
    this.progressBar = $('progress').down('div');
    this.request = false;
    this.resetTimer();
    new PeriodicalExecuter(this.updateTimer.bind(this), 1);
  },
  
  resetTimer: function() {
    this.progressBar.removeClassName('smooth');
    this.progressBar.setStyle({width: '100%'});
    setTimeout(function() {
      this.progressBar.addClassName('smooth');
      this.then = new Date().getTime();
    }.bind(this), 50);
  },
  
  updateTimer: function(executer) {
    var left = (RT.delay + (this.then - new Date().getTime()) / 1000);
    console.log(left);
    if (left > 0) {
      var width = left / RT.delay * 100;
      if (width < 0) {
        width = 0;
      }
      this.progressBar.setStyle({width: width + '%'});
    } else if (!this.request) {
      this.progressBar.setStyle({width: '0'});
      $(document.body).addClassName('loading');
      this.request = this.form.request({
        onComplete: function() {
          setTimeout(function() {  // TODO For development
            this.resetTimer();
            this.request = false;
            $(document.body).removeClassName('loading');
          }.bind(this), 2500);
        }.bind(this)
      });
    }
  }
});

new RT.Updater();