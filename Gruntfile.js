module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    emberhandlebars: {
      compile: {
        options: {
          templateName: function(sourceFile){
            var newSource = sourceFile.replace('assets/js/templates/', '');
            return newSource.replace('.hbs', '');
          }
        },
        files: ['assets/js/templates/*.hbs'],
        dest: 'assets/js/templates.js'
      }
    },

    watch: {
      files: ['assets/js/templates/*.hbs'],
      tasks: ['emberhandlebars:compile']
    }
  });

  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-ember-template-compiler');
};