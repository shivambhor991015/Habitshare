import 'package:flutter/material.dart';

class Habittile extends StatefulWidget {
  final int index;
  final int habitCounts;
  final int habitTimes;
  final List<List<String>> habits;

  const Habittile({
    Key? key,
    required this.index,
    required this.habitCounts,
    required this.habitTimes,
    required this.habits,
  }) : super(key: key);

  @override
  State<Habittile> createState() => _HabittileState();
}

class _HabittileState extends State<Habittile> {
  // Variables to keep track of counts and times for habits
  late int _habitCounts;
  late int _habitTimes;

  @override
  void initState() {
    super.initState();
    _habitCounts = widget.habitCounts;
    _habitTimes = widget.habitTimes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        title: Text(
          widget.habits[widget.index][0],
          style: TextStyle(
            fontSize: 25,
            color: Colors.black,
            fontWeight: FontWeight.w200,
          ),
        ),
        trailing: _buildTrailingWidget(widget.habits[widget.index]),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildActionIcon(Icons.check, Colors.green, () {
                // Handle tick action
              }),
              _buildActionIcon(Icons.close, Colors.red, () {
                // Handle cancel action
              }),
              _buildActionIcon(Icons.skip_next, Colors.orange, () {
                // Handle skip action
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingWidget(List<String> habit) {
    if (habit[1] == "count") {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildArrowButton(
            Icons.arrow_drop_up,
            () {
              setState(() {
                _habitCounts++;
              });
            },
          ),
          SizedBox(width: 5),
          Text(
            '$_habitCounts',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(width: 5),
          _buildArrowButton(
            Icons.arrow_drop_down,
            () {
              setState(() {
                if (_habitCounts > 0) {
                  _habitCounts--;
                }
              });
            },
          ),
        ],
      );
    } else if (habit[1] == "num") {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildArrowButton(
            Icons.arrow_drop_up,
            () {
              setState(() {
                _habitTimes++;
              });
            },
          ),
          Text(
            '$_habitTimes min',
            style: TextStyle(fontSize: 20),
          ),
          _buildArrowButton(
            Icons.arrow_drop_down,
            () {
              setState(() {
                if (_habitTimes > 0) {
                  _habitTimes--;
                }
              });
            },
          ),
        ],
      );
    } else {
      return Container(
        width: 0,
      ); // Empty container for habits without count or num
    }
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        icon: Icon(icon, size: 25), // Adjust the size as needed
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: onPressed,
        child: CircleAvatar(
          radius: 15,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
