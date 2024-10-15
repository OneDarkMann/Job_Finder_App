import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jop_finder_app/core/constants/app_colors.dart';
import 'package:jop_finder_app/features/auth/data/model/user_model.dart';
import 'package:jop_finder_app/features/profile/viewmodel/profile_cubit.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});
  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  ProfileCubit? profileCubit;
  String fileName = '';
  UserModel? user;

  @override
  void initState() {
    super.initState();
    profileCubit = BlocProvider.of<ProfileCubit>(context);
    // Schedule the asynchronous operation to fetch user information
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserInfo();
    });
  }

  Future<void> _fetchUserInfo() async {
    var fetchedUser =
        await BlocProvider.of<ProfileCubit>(context).getUserInfo();
    setState(() {
      user = fetchedUser;
    });
  }

  // Method to pick a PDF file
Future<FilePickerResult?> pickPDF() async {
  // Check and request storage permission
  PermissionStatus permissionStatus = await Permission.storage.request();
  if (permissionStatus.isGranted) {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],  // Only allow picking PDFs
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          fileName = result.files.single.name;
        });
        return result;
      } else {
        // User canceled the picker
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  } else {
    // Permission was denied, handle accordingly
    print('Permission denied');
    return null;
  }
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Resume'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resume or CV',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Color.fromARGB(255, 53, 104, 153), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                child: buildBlock(),
              ),
              const SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget buildBlock() {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is UserLoaded) {
          return uploadPrompt();
        } else if (state is UserUpdated) {
          return displayUploadedFile();
        } else if (state is ProfileError) {
          return Center(child: Text(state.errorMessage));
        } else {
          return const Center(child: Text('Error occurred'));
        }
      },
    );
  }

  Widget uploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
           SizedBox(height: 16),
            Icon(
              Icons.cloud_upload_outlined,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 4),
            Text(
              'Upload your CV or Resume\nand use it when you apply for jobs',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 250, 250, 250),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'Upload a PDF',
              style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          height: 50.sp,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 53, 104, 153),
          ),
          onPressed: () {
            pickPDF().then((cvPdf) {
              if (cvPdf != null) {
                profileCubit!.uploadCVAndUpdateUser(cvPdf);
              }
            });
          }, // add your save function here
          child: const SizedBox(
              width: double.infinity,
              height: 50,
              child: Center(
                  child: Text(
                'Upload',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ))),
        ),
      ],
    );
  }

  Widget displayUploadedFile() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 50,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        Text(
          'File Uploaded: $fileName',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}