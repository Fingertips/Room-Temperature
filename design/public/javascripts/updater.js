if (typeof RT == "undefined") RT = {};

RT.delay = 3;

RT.Updater = Class.create({
  initialize: function() {
    this.form = $('vote').down('form');
    this.progressBar = $('progress').down('div');
    this.results = $('results');
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
  
  mostRecentMinuteId: function() {
    return this.results.down('div.m').id.substring(2);
  },
  
  updateTimer: function(executer) {
    var left = (RT.delay + (this.then - new Date().getTime()) / 1000);
    if (left > 0) {
      var width = left / RT.delay * 100;
      if (width < 0) {
        width = 0;
      }
      this.progressBar.setStyle({width: width + '%'});
    } else if (!this.request) {
      this.progressBar.setStyle({width: '0'});
      $(document.body).addClassName('loading');
      var id = this.mostRecentMinuteId();
      var url = this.form.getAttribute('action') + '?id=' + id;
      console.log(url);
      url = url.gsub('?id=', '-');  // TODO For development
      this.request = new Ajax.Request(url, {
        parameters: this.form.serialize(true),
        onSuccess: function(response) {
          if (id == this.mostRecentMinuteId()) {
            this.results.insert({top: response.responseText});
          }
        }.bind(this),
        onComplete: function(response) {
          this.resetTimer();
          this.request = false;
          $(document.body).removeClassName('loading');
        }.bind(this)
      });
    }
  }
});

new RT.Updater();