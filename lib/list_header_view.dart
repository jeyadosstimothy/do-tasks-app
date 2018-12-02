import 'package:flutter/material.dart';
import 'package:to_do/db_schema.dart';

typedef void OnPressTaskCallback(Task task);

class ListHeaderView extends StatelessWidget {
  final TaskList tasks;
  final String title;
  final IconData leading, trailing;
  final OnPressTaskCallback onPressLeading, onPressTrailing;
  final bool divided;

  ListHeaderView({@required this.tasks, this.title, this.leading, this.trailing, this.onPressLeading, this.onPressTrailing, this.divided});

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> tiles = tasks.map(
      (task) => ListTile(
        title: Text(task.getTaskName(), style: Theme.of(context).textTheme.subhead),
        leading: ((leading!=null)?
          IconButton(icon: Icon(leading), onPressed: ((onPressLeading != null)?(() => onPressLeading(task)): null)):
          null
        ),
        trailing: ((trailing!=null)?
          IconButton(icon: Icon(trailing), onPressed: ((onPressTrailing != null)?(() => onPressTrailing(task)): null)):
          null
        ),
      )
    );
    List<Widget> dividedTiles = (divided? ListTile.divideTiles(context: context, tiles: tiles).toList() : tiles.toList());
    if(title != null) {
      dividedTiles.insert(0, ListTile(
        title: Text(title, style: Theme.of(context).textTheme.title)
      ));
    }
    return ListView(children: dividedTiles);
  }

/*
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      itemBuilder: (BuildContext context, int index, Animation animation) {
        return FadeTransition(
          opacity: animation,
          child: ((index==0)? ListTile(title: Text(title, style: Theme.of(context).textTheme.title)) :
            ListTile(
              title: Text(tasks[index].getTaskName(), style: Theme.of(context).textTheme.subhead),
              leading: ((leading!=null)?
                IconButton(icon: Icon(leading), onPressed: ((onPressLeading != null)?(() => onPressLeading(tasks[index])): null)):
                null
              ),
              trailing: ((trailing!=null)?
                IconButton(icon: Icon(trailing), onPressed: ((onPressTrailing != null)?(() => onPressTrailing(tasks[index])): null)):
                null
              ),
            )
          )
        );
      }
    );
  }*/
}