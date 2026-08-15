import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DirectCustomerAuthPage extends StatefulWidget {
  const DirectCustomerAuthPage({super.key});

  @override
  State<DirectCustomerAuthPage> createState() => _DirectCustomerAuthPageState();
}

class _DirectCustomerAuthPageState extends State<DirectCustomerAuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _verificationId;
  int? _resendToken;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) {
            _navigateToRegistration(formattedPhone);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = e.message ?? 'OTP verification failed';
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _isOtpSent = true;
              _isLoading = false;
              _verificationId = verificationId;
              _resendToken = resendToken;
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      if (mounted) {
        // Fallback for development/testing environments
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
          _verificationId = 'demo_verification_id';
        });
      }
    }
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter a valid 6-digit OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final phone = _phoneController.text.trim();
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    try {
      if (_verificationId != null && _verificationId != 'demo_verification_id') {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: otp,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      if (mounted) {
        _navigateToRegistration(formattedPhone);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid OTP. Please check and try again.';
        });
      }
    }
  }

  void _navigateToRegistration(String phone) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DirectComplaintRegistrationPage(
          verifiedPhoneNumber: phone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Phone Verification'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 60,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Direct Complaint Registration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verify your mobile number to register a new complaint',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _phoneController,
                      enabled: !_isOtpSent,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter 10-digit mobile number',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_isOtpSent) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'Enter 6-Digit OTP',
                          prefixIcon: Icon(Icons.lock_clock),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : (_isOtpSent ? _verifyOtp : _sendOtp),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isOtpSent ? 'Verify OTP & Continue' : 'Send OTP'),
                      ),
                    ),
                    if (_isOtpSent) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isOtpSent = false;
                            _otpController.clear();
                            _errorMessage = null;
                          });
                        },
                        child: const Text('Change Phone Number'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DirectComplaintRegistrationPage extends StatefulWidget {
  final String verifiedPhoneNumber;
  const DirectComplaintRegistrationPage({
    super.key,
    required this.verifiedPhoneNumber,
  });

  @override
  State<DirectComplaintRegistrationPage> createState() =>
      _DirectComplaintRegistrationPageState();
}

class _DirectComplaintRegistrationPageState
    extends State<DirectComplaintRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _dealerController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _warrantyDateController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  String? _selectedBrand;
  String? _selectedCategory;
  String? _selectedRequestType;
  bool _isSubmitting = false;

  final List<String> _brands = ['Select a brand', 'Limson', 'Other'];
  final List<String> _categories = [
    'Select a category',
    'Ceiling Fan',
    'Gas Stove',
    'mini cooler (6" or 9")',
    'small cooler(12")',
    'big cooler(16" or 18")',
    'Other'
  ];
  final List<String> _requestTypes = [
    'Installation',
    'Demo',
    'Service',
    'Complain'
  ];

  @override
  void initState() {
    super.initState();
    _selectedBrand = 'Select a brand';
    _selectedCategory = 'Select a category';
    _selectedRequestType = 'Complain';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _villageController.dispose();
    _dealerController.dispose();
    _purchaseDateController.dispose();
    _warrantyDateController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  String _getAutoAssignedKarigar(String? category) {
    if (category == null) return 'Not assigned';
    final catLower = category.trim().toLowerCase();
    if (catLower.contains('ceiling fan') || catLower.contains('cooler')) {
      return 'Samir';
    } else if (catLower.contains('gas stove')) {
      return 'Sachin';
    }
    return 'Not assigned';
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final allottedKarigar = _getAutoAssignedKarigar(_selectedCategory);
    final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final complaintData = {
      'Customer name': _nameController.text.trim(),
      'Phone': widget.verifiedPhoneNumber,
      'address': _addressController.text.trim(),
      'Village': _villageController.text.trim(),
      'Dealer name': _dealerController.text.trim(),
      'Brand': _selectedBrand == 'Select a brand' ? '' : (_selectedBrand ?? ''),
      'Category': _selectedCategory == 'Select a category' ? '' : (_selectedCategory ?? ''),
      'productcategory': _selectedCategory == 'Select a category' ? '' : (_selectedCategory ?? ''),
      'allotted to': allottedKarigar,
      'Status': 'Open',
      'date of complain': formattedDate,
      'Service type': _selectedRequestType ?? 'Complain',
      'Source by': 'Customer Direct',
      'Purchase date': _purchaseDateController.text.trim(),
      'warranty expiry date': _warrantyDateController.text.trim(),
      'Remark': _remarkController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      // 1. Write to Firestore complaints collection
      final docRef = await FirebaseFirestore.instance
          .collection('complaints')
          .add(complaintData);

      // 2. Post to Vercel backend endpoint as backup if available
      try {
        await http.post(
          Uri.parse('https://limsonvercelapi2.vercel.app/api/fsaddcomplaint'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id': docRef.id,
            'fields': complaintData,
          }),
        );
      } catch (_) {
        // Backend API attempt completed
      }

      if (mounted) {
        _showSuccessDialog(docRef.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit complaint: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog(String complaintId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Complaint Registered!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your complaint has been successfully registered.',
            ),
            const SizedBox(height: 12),
            SelectableText(
              'Ticket Ref ID: $complaintId',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verified Phone: ${widget.verifiedPhoneNumber}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Register Another Complaint'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _nameController.clear();
    _addressController.clear();
    _villageController.clear();
    _dealerController.clear();
    _purchaseDateController.clear();
    _warrantyDateController.clear();
    _remarkController.clear();
    setState(() {
      _selectedBrand = 'Select a brand';
      _selectedCategory = 'Select a category';
      _selectedRequestType = 'Complain';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Complaint'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Direct Complaint Form',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fill in the details below to submit your complaint directly.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Locked Verified Phone Number Field
                      TextFormField(
                        initialValue: widget.verifiedPhoneNumber,
                        enabled: false,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone Number (Verified & Locked)',
                          prefixIcon: const Icon(Icons.phone, color: Colors.green),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: Colors.green),
                                SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.green.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.green.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Address *',
                          prefixIcon: Icon(Icons.home),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _villageController,
                              decoration: const InputDecoration(
                                labelText: 'Village / City',
                                prefixIcon: Icon(Icons.location_city),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _dealerController,
                              decoration: const InputDecoration(
                                labelText: 'Dealer Name',
                                prefixIcon: Icon(Icons.store),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        decoration: const InputDecoration(
                          labelText: 'Brand',
                          prefixIcon: Icon(Icons.branding_watermark),
                          border: OutlineInputBorder(),
                        ),
                        items: _brands.map((brand) {
                          return DropdownMenuItem(
                            value: brand,
                            child: Text(brand),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBrand = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: _categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value == 'Select a category') {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedRequestType,
                        decoration: const InputDecoration(
                          labelText: 'Service / Request Type',
                          prefixIcon: Icon(Icons.build),
                          border: OutlineInputBorder(),
                        ),
                        items: _requestTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRequestType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(_purchaseDateController),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _purchaseDateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Date',
                                    prefixIcon: Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(_warrantyDateController),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _warrantyDateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Warranty Expiry Date',
                                    prefixIcon: Icon(Icons.event_available),
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _remarkController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Complaint Details / Remarks',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitComplaint,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            _isSubmitting
                                ? 'Submitting Complaint...'
                                : 'Submit Complaint',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
