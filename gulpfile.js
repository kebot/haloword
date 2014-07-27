var gulp = require('gulp'),
    es6ModuleTranspiler = require('gulp-es6-module-transpiler'),
    coffee = require('gulp-coffee'),
    es = require('event-stream'),
    watch = require('gulp-watch'),
    plumber = require('gulp-plumber'),
    notify = require('gulp-notify'),
    browserSync = require('browser-sync');

const scriptsDir = './release/javascript/';

// coffeescript or javscript -> es6-module-trans
gulp.task('default', function() {
    var errorHandler = plumber({'errorHandler': notify.onError('Error: <%= error.message %>')})
    watch({
        glob: 'src/**/*.coffee'
    }, function(files){
        files
            .pipe(plumber({'errorHandler': notify.onError('Error: <%= error.message %>')}))
            .pipe(coffee({bare: true}))
            // .pipe(es6ModuleTranspiler({type: 'amd'}))
            .pipe(gulp.dest(scriptsDir));
    });

    watch({
        glob: 'src/**/*.js'
    }, function(files){
        files
            .pipe(plumber({'errorHandler': notify.onError('Error: <%= error.message %>')}))
            .pipe(es6ModuleTranspiler({type: 'amd'}))
            .pipe(gulp.dest(scriptsDir));
    });

    browserSync.init([
        'release/**/*.js',
        'release/**/*.css',
        'release/**/*.html'
    ], {
        server: {
            baseDir: '.',
            index: 'index.html'
        }
    });
    console.log('Start watch src/**/*.coffee.');
});

gulp.task('scripts', function() {
    es.merge(
        gulp.src('src/**/*.js'),
        gulp.src('src/**/*.coffee')
           .pipe(coffee({bare: true}))
    ).pipe(es6ModuleTranspiler({
        type: 'cjs'
    }))
    .pipe(gulp.dest(scriptsDir));
})

