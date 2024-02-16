SetFactory("OpenCASCADE");

WW = 1.0;   // �ǂ̌���
WL = 8.0;   // �ǂ̕��iY�����j
BW = 5.0;   // ��b��X��������
BH = 1.0;   // ��b�̌����iZ�����j
SW = 10.0;  // �n�Ղ�X��������
SL = 6.0;   // ��b�˒n�ՁiY�����j
SH = 10.0;  // �n�Ղ̌����iZ�����j�}�C�i�X������
WH = 5.0;   // �ǂ̍����iZ�����j

NWW = 3;    // �ǂ̌��������̕������iX�����j
NWL = 3;    // �ǂ̕��̕������iY�����j
NBW = 3;    // �ǁˊ�b�[���̊Ԃ̕������iX�����j
NSW = 3;    // ��b�˒n�Ղ̊Ԃ̕������iX�����j
NSL = 3;    // ��b�˒n�Ղ̊Ԃ̕������iY�����j
NSH = 5;    // �n�Ղ̌����̕�����
NBH = 2;    // ��b�̌����̕�����
NWH = 4;    // �ǂ̍����̕�����

Point(1)   = {0,    WL/2, 0};  // �ǂ̎n�_
Point(2)   = {WW/2, WL/2, 0};  // �ǂ̌���(X����)
Point(3)   = {BW/2, WL/2, 0};  // ��b��X��������
Point(4)   = {SW/2, WL/2, 0};  // �n�Ղ�X��������

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Transfinite Curve {1} = NWW Using Bump 1;
Transfinite Curve {2} = NBW Using Bump 1;
Transfinite Curve {3} = NSW Using Bump 1;

// �n�Ղ��������։��o���iZ�����j
Extrude {0, 0, -SH} {
  Curve{1}; Curve{2}; Curve{3}; Layers {NSH}; Recombine;
}
// ��b��������։��o���iZ�����j
Extrude {0, 0, BH} {
  Curve{1}; Curve{2}; Layers {NBH}; Recombine;
}

// �ǂ�������։��o��
Extrude {0, 0, WH} {
  Curve{13}; Layers {NWH}; Recombine;
}

// �ǂ̕������։��o��
Extrude {0, -WL/2, 0} {
  Surface{1:6}; Layers {NWL}; Recombine;
}
// �n�Ղ�Y�����։��o��
Extrude {0, SL, 0} {
  Surface{3}; Surface{2}; Surface{1}; Layers {NSL}; Recombine;
}

// ----- ("�v�f�L�[���[�h", �ޗ��ԍ�) -----
// ���v�f�L�[���[�h�͔C�ӂ�5�������d����NG
// ���ޗ��ԍ��́AHEAT��MTRL & INDP�ƈ�v������
// 
// ----- �v�f�̐ݒ� -----
Physical Volume("CON1") = {5, 4};              // ��b
Physical Volume("CON2") = {6};                 // ��
Physical Volume("SOIL1") = {1, 2, 3, 9, 8, 7};  // �n��
// ----- �ߓ_�Œ� -----
Physical Surface("FIXX") = { 7, 20, 27, 40};          // MECH
Physical Surface("FIXY") = {11, 15, 19, 23, 26, 30};  // MECH
Physical Surface("FIXZ") = {10, 14, 18, 34, 38, 42};  // MECH, HEAT, HYGR

// ----- TRNS -----
Physical Surface("AIR1") = {17, 33, 37, 41};  // �n�Տ�ʂ�TRNS
Physical Surface("AIR2") = {4, 5, 24, 25};    // ��b�\�ʂ�TRNS
Physical Surface("AIR3") = {22};              // ��b�\�ʂ�TRNS(inner)
Physical Surface("AIR4") = {6, 28, 29};       // �Ǖ\�ʂ�TRNS


