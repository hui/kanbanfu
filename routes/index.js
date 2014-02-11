
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'KanbanFu.com - The missing project management tool for Trello. Team activities and cumulative flow chart.' });
};