import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/domains/exercise.dart';
import 'package:flutter_app/domains/muscle_group.dart';
import 'package:flutter_app/domains/muscle_group.dart';
import 'package:flutter_app/domains/muscle_group.dart';
import 'package:flutter_app/providers/exercises_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

class MuscleGroupDropdown extends StatefulWidget {
  final TextEditingController? dropdownSearchController;
  final Function(MuscleGroup?) onChangeCallback;
  final MuscleGroup? selectedItem;

  const MuscleGroupDropdown({Key? key, this.dropdownSearchController, required this.onChangeCallback, this.selectedItem})
      : super(key: key);

  @override
  State<MuscleGroupDropdown> createState() => _MuscleGroupDropdownState();
}

class _MuscleGroupDropdownState extends State<MuscleGroupDropdown> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.dropdownSearchController ?? TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ExercisesProvider>(context, listen: false).fetchMuscleGroups().then((value) {
        // widget.onChangeCallback(context.read<ExercisesProvider>().list.first.id);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ExercisesProvider>(
        builder: (context, provider, child) {
          return provider.isLoading ? Container(height: 50, child: const Center(child: CircularProgressIndicator()),) : DropdownSearch<MuscleGroup>(
            mode: Mode.MENU,
            showSearchBox: true,
            items: context.watch<ExercisesProvider>().groups,
            itemAsString: (MuscleGroup? item) => item?.name ?? '',
            // popupItemDisabled: (MuscleGroup? item) => widget.disabledItems.contains(item?.id),
            onChanged: (MuscleGroup? item) {
              widget.onChangeCallback(item);
            },
            selectedItem: widget.selectedItem,
            popupItemBuilder: (BuildContext context, MuscleGroup? item, bool isSelected,) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                decoration: !isSelected
                    ? null
                    : BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
                child: ListTile(
                  selected: isSelected,
                  title: Text(item?.name ?? ''),
                ),
              );
            },
            searchFieldProps: TextFieldProps(
              controller: controller,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                  },
                ),
              ),
            ),

          );
        }
    );
  }
}