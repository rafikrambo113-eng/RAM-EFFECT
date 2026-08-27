# RAm EFFECT

تطبيق محاكاة رِج جيتار (Guitar Rig / Pedalboard Simulator) مبني بـ Flutter.

## المميزات الحالية
- Pedalboard فيه دواسات Overdrive, Delay, Reverb, Chorus قابلة للتشغيل/الإطفاء
- قسم أمبلفاير (TUBE MASTER 50) بمفاتيح Gain, Bass, Treble, Volume
- دواستين Expression جانبيتين (Volume, Wah)
- نظام حفظ Boards/Presets غير محدود مع قائمة جانبية (Drawer) للتنقل بينها

## الأجهزة المستهدفة
- تابلت Lenovo Tab One
- إنترفيس جيتار iRig (توصيل الجيتار عن طريق مدخل 3.5mm)

## خطط مستقبلية
- حفظ دائم للـ Presets (بدل التخزين المؤقت في الذاكرة)
- ربط كل Preset بالقيم الفعلية لإعدادات الدواسات والأمبلي
- معالجة صوت حقيقية بزمن استجابة منخفض (Low Latency) من مدخل iRig باستخدام مكتبات صوت Native (Oboe/AAudio)

## طريقة التشغيل
```bash
flutter pub get
flutter run
```

## البنية
```
lib/
  main.dart   # الكود الرئيسي للتطبيق
pubspec.yaml  # إعدادات المشروع والمكتبات
```
