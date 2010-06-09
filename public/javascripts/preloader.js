if (typeof RT == "undefined") RT = {};

RT.Preloader = Class.create({
  initialize: function(images, callback){
    if (typeof images == "string") images = [images];
    this.images = images;
    this.counter = 0;
    this.callback = callback || function(){};
    
    if (this.images.length == 0) {
      this.callback();
      return;
    }
    
    var self = this;
    this.images.each(function(image, index){
      window.setTimeout(self.loadImage.curry(image).bind(self), index*100);
    });
  },
  
  loadImage: function(image, callback) {
    var img = new Image();
    img.observe("load", this.imageLoaded.bind(this));
    img.src = image;
  },
  
  imageLoaded: function() {
    this.counter++;
    if (this.counter == this.images.length) {
      this.callback(this.images);
    }
  }
});

new RT.Preloader([
  '/stylesheets/images/hd/star-unselected-hover.png',
  '/stylesheets/images/hd/star-unselected-active.png',
  '/stylesheets/images/hd/star-selected.png',
  '/stylesheets/images/hd/star-selected-hover.png',
  '/stylesheets/images/hd/star-selected-active.png'
]);