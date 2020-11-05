import 'dart:ui';

import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flame/game/base_game.dart';
import 'package:flutter/material.dart';
import 'package:flame/animation.dart' as animation;


class MyFirstGame extends BaseGame with HasWidgetsOverlay{
  Player player;
  Enemy enemy;
  Color color;
  MyFirstGame(){
    player=Player();
    enemy=Enemy();
    add(enemy);
    add(player);
    createControls();
  }


  @override
  void update(double t) {
    player.update(t);
    enemy.update(t);
    if(checkCollision()){
      player.color=Colors.red;
    }else{
      player.color=Colors.white;
    }
  }

  checkCollision(){

    print("value 1 ${player.x<enemy.x + enemy.width}"
        " value 2 ${player.x + player.width>enemy.x}"
    " Value 3 ${player.y<enemy.y+enemy.height}"
    " Value 4 ${player.y + player.height>enemy.y}");
    return player.x<enemy.x + enemy.width &&
    player.x + player.width>enemy.x &&
    player.y<enemy.y+enemy.height &&
    player.y + player.height>enemy.y;

  }

  createControls(){
    addWidgetOverlay("Controls",
    Stack(children: <Widget>[
      Positioned(left:10,bottom:10,child:Row(children: <Widget>[
        gameButton(path:"assets/images/left_arrow.png",onTapDown: movingLeft,onTapUp: stopMoving),
        gameButton(path:"assets/images/right_arrow.png",onTapDown: movingRight,onTapUp: stopMoving),
      ],)),
      Positioned(right:10,bottom:10,child:Column(children: <Widget>[
        gameButton(path:"assets/images/up_arrow.png",onTapDown: jumping,),
        gameButton(path:"assets/images/down_arrow.png",onTapDown: ducking,),
      ],))
    ],));
  }

  gameButton({path,onTapDown,onTapUp}){
    return GestureDetector(
      onTapDown: (detailDown)=>onTapDown(),
      onTapUp:(onTapUp!=null)? (detailUp)=>onTapUp():null,
      child: Container(
        child: Image.asset(path),
        width: 70,
        height: 70,
        margin: EdgeInsets.all(2),
      ),
    );
  }

  ducking(){
    player.axisY=20;
    player.status=Status.ducking;
  }

  jumping(){
    player.axisY=20;
    player.status=Status.jumping;
  }
  movingRight(){
    player.axisX=10;
  }
  movingLeft(){
   player.axisX=-10;
  }
  stopMoving(){
    player.axisX=0;
  }
}
class Enemy extends AnimationComponent{
  Enemy():super(100, 100,
  animation.Animation.sequenced("bug.png", 2,textureX: 0,textureY: 0,amountPerRow: 2,loop: true,stepTime: 0.2,textureHeight: 481,textureWidth: 582));


  @override
  void resize(Size size) {
    x=size.width/2;
    y=size.height/3;
  }

}


enum Status {ducking,start,jumping}
class Player extends PositionComponent{
  double startPositionX=0;
  double startPositionY=0;
  Color color=Colors.white;
  double speed=20;
  double axisX=0;
  double axisY=0;
  Status status;

  Player(){
    width=100;
    height=100;
  }

  @override
  void render(Canvas c) {
    c.drawRect(toRect(), Paint()..color=color);
  }

  @override
  void resize(Size size) {
    startPositionY=size.height/3;
    startPositionX=size.width/8;
    x=startPositionX;
    y=startPositionY;
  }

  @override
  void update(double dt) {
    x+= speed * dt * axisX;
    switch(status){
      case Status.ducking:
        y+=axisY;
        if(y > startPositionY)
          reset();
        break;
      case Status.jumping:
        y-=axisY;
        axisY=axisY-1;
        if(y > startPositionY)
          reset();
        break;
      case Status.start:
        y=startPositionY;

    }
  }


  reset(){
    status=Status.start;
  }
}