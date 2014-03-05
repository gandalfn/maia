/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * keysym.vala
 * Copyright (C) Nicolas Bruguier 2010-2013 <gandalfn@club-internet.fr>
 *
 * maia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * maia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Maia.Xcb
{
    struct CodePair {
        global::Xcb.Keysym keysym;
        unichar ucs;
    }

    const CodePair[] c_KeysymTab = {
        { 0x01a1, 0x0104 }, /*                     Aogonek Ą LATIN CAPITAL LETTER A WITH OGONEK */
        { 0x01a2, 0x02d8 }, /*                       breve ˘ BREVE */
        { 0x01a3, 0x0141 }, /*                     Lstroke Ł LATIN CAPITAL LETTER L WITH STROKE */
        { 0x01a5, 0x013d }, /*                      Lcaron Ľ LATIN CAPITAL LETTER L WITH CARON */
        { 0x01a6, 0x015a }, /*                      Sacute Ś LATIN CAPITAL LETTER S WITH ACUTE */
        { 0x01a9, 0x0160 }, /*                      Scaron Š LATIN CAPITAL LETTER S WITH CARON */
        { 0x01aa, 0x015e }, /*                    Scedilla Ş LATIN CAPITAL LETTER S WITH CEDILLA */
        { 0x01ab, 0x0164 }, /*                      Tcaron Ť LATIN CAPITAL LETTER T WITH CARON */
        { 0x01ac, 0x0179 }, /*                      Zacute Ź LATIN CAPITAL LETTER Z WITH ACUTE */
        { 0x01ae, 0x017d }, /*                      Zcaron Ž LATIN CAPITAL LETTER Z WITH CARON */
        { 0x01af, 0x017b }, /*                   Zabovedot Ż LATIN CAPITAL LETTER Z WITH DOT ABOVE */
        { 0x01b1, 0x0105 }, /*                     aogonek ą LATIN SMALL LETTER A WITH OGONEK */
        { 0x01b2, 0x02db }, /*                      ogonek ˛ OGONEK */
        { 0x01b3, 0x0142 }, /*                     lstroke ł LATIN SMALL LETTER L WITH STROKE */
        { 0x01b5, 0x013e }, /*                      lcaron ľ LATIN SMALL LETTER L WITH CARON */
        { 0x01b6, 0x015b }, /*                      sacute ś LATIN SMALL LETTER S WITH ACUTE */
        { 0x01b7, 0x02c7 }, /*                       caron ˇ CARON */
        { 0x01b9, 0x0161 }, /*                      scaron š LATIN SMALL LETTER S WITH CARON */
        { 0x01ba, 0x015f }, /*                    scedilla ş LATIN SMALL LETTER S WITH CEDILLA */
        { 0x01bb, 0x0165 }, /*                      tcaron ť LATIN SMALL LETTER T WITH CARON */
        { 0x01bc, 0x017a }, /*                      zacute ź LATIN SMALL LETTER Z WITH ACUTE */
        { 0x01bd, 0x02dd }, /*                 doubleacute ˝ DOUBLE ACUTE ACCENT */
        { 0x01be, 0x017e }, /*                      zcaron ž LATIN SMALL LETTER Z WITH CARON */
        { 0x01bf, 0x017c }, /*                   zabovedot ż LATIN SMALL LETTER Z WITH DOT ABOVE */
        { 0x01c0, 0x0154 }, /*                      Racute Ŕ LATIN CAPITAL LETTER R WITH ACUTE */
        { 0x01c3, 0x0102 }, /*                      Abreve Ă LATIN CAPITAL LETTER A WITH BREVE */
        { 0x01c5, 0x0139 }, /*                      Lacute Ĺ LATIN CAPITAL LETTER L WITH ACUTE */
        { 0x01c6, 0x0106 }, /*                      Cacute Ć LATIN CAPITAL LETTER C WITH ACUTE */
        { 0x01c8, 0x010c }, /*                      Ccaron Č LATIN CAPITAL LETTER C WITH CARON */
        { 0x01ca, 0x0118 }, /*                     Eogonek Ę LATIN CAPITAL LETTER E WITH OGONEK */
        { 0x01cc, 0x011a }, /*                      Ecaron Ě LATIN CAPITAL LETTER E WITH CARON */
        { 0x01cf, 0x010e }, /*                      Dcaron Ď LATIN CAPITAL LETTER D WITH CARON */
        { 0x01d0, 0x0110 }, /*                     Dstroke Đ LATIN CAPITAL LETTER D WITH STROKE */
        { 0x01d1, 0x0143 }, /*                      Nacute Ń LATIN CAPITAL LETTER N WITH ACUTE */
        { 0x01d2, 0x0147 }, /*                      Ncaron Ň LATIN CAPITAL LETTER N WITH CARON */
        { 0x01d5, 0x0150 }, /*                Odoubleacute Ő LATIN CAPITAL LETTER O WITH DOUBLE ACUTE */
        { 0x01d8, 0x0158 }, /*                      Rcaron Ř LATIN CAPITAL LETTER R WITH CARON */
        { 0x01d9, 0x016e }, /*                       Uring Ů LATIN CAPITAL LETTER U WITH RING ABOVE */
        { 0x01db, 0x0170 }, /*                Udoubleacute Ű LATIN CAPITAL LETTER U WITH DOUBLE ACUTE */
        { 0x01de, 0x0162 }, /*                    Tcedilla Ţ LATIN CAPITAL LETTER T WITH CEDILLA */
        { 0x01e0, 0x0155 }, /*                      racute ŕ LATIN SMALL LETTER R WITH ACUTE */
        { 0x01e3, 0x0103 }, /*                      abreve ă LATIN SMALL LETTER A WITH BREVE */
        { 0x01e5, 0x013a }, /*                      lacute ĺ LATIN SMALL LETTER L WITH ACUTE */
        { 0x01e6, 0x0107 }, /*                      cacute ć LATIN SMALL LETTER C WITH ACUTE */
        { 0x01e8, 0x010d }, /*                      ccaron č LATIN SMALL LETTER C WITH CARON */
        { 0x01ea, 0x0119 }, /*                     eogonek ę LATIN SMALL LETTER E WITH OGONEK */
        { 0x01ec, 0x011b }, /*                      ecaron ě LATIN SMALL LETTER E WITH CARON */
        { 0x01ef, 0x010f }, /*                      dcaron ď LATIN SMALL LETTER D WITH CARON */
        { 0x01f0, 0x0111 }, /*                     dstroke đ LATIN SMALL LETTER D WITH STROKE */
        { 0x01f1, 0x0144 }, /*                      nacute ń LATIN SMALL LETTER N WITH ACUTE */
        { 0x01f2, 0x0148 }, /*                      ncaron ň LATIN SMALL LETTER N WITH CARON */
        { 0x01f5, 0x0151 }, /*                odoubleacute ő LATIN SMALL LETTER O WITH DOUBLE ACUTE */
        { 0x01f8, 0x0159 }, /*                      rcaron ř LATIN SMALL LETTER R WITH CARON */
        { 0x01f9, 0x016f }, /*                       uring ů LATIN SMALL LETTER U WITH RING ABOVE */
        { 0x01fb, 0x0171 }, /*                udoubleacute ű LATIN SMALL LETTER U WITH DOUBLE ACUTE */
        { 0x01fe, 0x0163 }, /*                    tcedilla ţ LATIN SMALL LETTER T WITH CEDILLA */
        { 0x01ff, 0x02d9 }, /*                    abovedot ˙ DOT ABOVE */
        { 0x02a1, 0x0126 }, /*                     Hstroke Ħ LATIN CAPITAL LETTER H WITH STROKE */
        { 0x02a6, 0x0124 }, /*                 Hcircumflex Ĥ LATIN CAPITAL LETTER H WITH CIRCUMFLEX */
        { 0x02a9, 0x0130 }, /*                   Iabovedot İ LATIN CAPITAL LETTER I WITH DOT ABOVE */
        { 0x02ab, 0x011e }, /*                      Gbreve Ğ LATIN CAPITAL LETTER G WITH BREVE */
        { 0x02ac, 0x0134 }, /*                 Jcircumflex Ĵ LATIN CAPITAL LETTER J WITH CIRCUMFLEX */
        { 0x02b1, 0x0127 }, /*                     hstroke ħ LATIN SMALL LETTER H WITH STROKE */
        { 0x02b6, 0x0125 }, /*                 hcircumflex ĥ LATIN SMALL LETTER H WITH CIRCUMFLEX */
        { 0x02b9, 0x0131 }, /*                    idotless ı LATIN SMALL LETTER DOTLESS I */
        { 0x02bb, 0x011f }, /*                      gbreve ğ LATIN SMALL LETTER G WITH BREVE */
        { 0x02bc, 0x0135 }, /*                 jcircumflex ĵ LATIN SMALL LETTER J WITH CIRCUMFLEX */
        { 0x02c5, 0x010a }, /*                   Cabovedot Ċ LATIN CAPITAL LETTER C WITH DOT ABOVE */
        { 0x02c6, 0x0108 }, /*                 Ccircumflex Ĉ LATIN CAPITAL LETTER C WITH CIRCUMFLEX */
        { 0x02d5, 0x0120 }, /*                   Gabovedot Ġ LATIN CAPITAL LETTER G WITH DOT ABOVE */
        { 0x02d8, 0x011c }, /*                 Gcircumflex Ĝ LATIN CAPITAL LETTER G WITH CIRCUMFLEX */
        { 0x02dd, 0x016c }, /*                      Ubreve Ŭ LATIN CAPITAL LETTER U WITH BREVE */
        { 0x02de, 0x015c }, /*                 Scircumflex Ŝ LATIN CAPITAL LETTER S WITH CIRCUMFLEX */
        { 0x02e5, 0x010b }, /*                   cabovedot ċ LATIN SMALL LETTER C WITH DOT ABOVE */
        { 0x02e6, 0x0109 }, /*                 ccircumflex ĉ LATIN SMALL LETTER C WITH CIRCUMFLEX */
        { 0x02f5, 0x0121 }, /*                   gabovedot ġ LATIN SMALL LETTER G WITH DOT ABOVE */
        { 0x02f8, 0x011d }, /*                 gcircumflex ĝ LATIN SMALL LETTER G WITH CIRCUMFLEX */
        { 0x02fd, 0x016d }, /*                      ubreve ŭ LATIN SMALL LETTER U WITH BREVE */
        { 0x02fe, 0x015d }, /*                 scircumflex ŝ LATIN SMALL LETTER S WITH CIRCUMFLEX */
        { 0x03a2, 0x0138 }, /*                         kra ĸ LATIN SMALL LETTER KRA */
        { 0x03a3, 0x0156 }, /*                    Rcedilla Ŗ LATIN CAPITAL LETTER R WITH CEDILLA */
        { 0x03a5, 0x0128 }, /*                      Itilde Ĩ LATIN CAPITAL LETTER I WITH TILDE */
        { 0x03a6, 0x013b }, /*                    Lcedilla Ļ LATIN CAPITAL LETTER L WITH CEDILLA */
        { 0x03aa, 0x0112 }, /*                     Emacron Ē LATIN CAPITAL LETTER E WITH MACRON */
        { 0x03ab, 0x0122 }, /*                    Gcedilla Ģ LATIN CAPITAL LETTER G WITH CEDILLA */
        { 0x03ac, 0x0166 }, /*                      Tslash Ŧ LATIN CAPITAL LETTER T WITH STROKE */
        { 0x03b3, 0x0157 }, /*                    rcedilla ŗ LATIN SMALL LETTER R WITH CEDILLA */
        { 0x03b5, 0x0129 }, /*                      itilde ĩ LATIN SMALL LETTER I WITH TILDE */
        { 0x03b6, 0x013c }, /*                    lcedilla ļ LATIN SMALL LETTER L WITH CEDILLA */
        { 0x03ba, 0x0113 }, /*                     emacron ē LATIN SMALL LETTER E WITH MACRON */
        { 0x03bb, 0x0123 }, /*                    gcedilla ģ LATIN SMALL LETTER G WITH CEDILLA */
        { 0x03bc, 0x0167 }, /*                      tslash ŧ LATIN SMALL LETTER T WITH STROKE */
        { 0x03bd, 0x014a }, /*                         ENG Ŋ LATIN CAPITAL LETTER ENG */
        { 0x03bf, 0x014b }, /*                         eng ŋ LATIN SMALL LETTER ENG */
        { 0x03c0, 0x0100 }, /*                     Amacron Ā LATIN CAPITAL LETTER A WITH MACRON */
        { 0x03c7, 0x012e }, /*                     Iogonek Į LATIN CAPITAL LETTER I WITH OGONEK */
        { 0x03cc, 0x0116 }, /*                   Eabovedot Ė LATIN CAPITAL LETTER E WITH DOT ABOVE */
        { 0x03cf, 0x012a }, /*                     Imacron Ī LATIN CAPITAL LETTER I WITH MACRON */
        { 0x03d1, 0x0145 }, /*                    Ncedilla Ņ LATIN CAPITAL LETTER N WITH CEDILLA */
        { 0x03d2, 0x014c }, /*                     Omacron Ō LATIN CAPITAL LETTER O WITH MACRON */
        { 0x03d3, 0x0136 }, /*                    Kcedilla Ķ LATIN CAPITAL LETTER K WITH CEDILLA */
        { 0x03d9, 0x0172 }, /*                     Uogonek Ų LATIN CAPITAL LETTER U WITH OGONEK */
        { 0x03dd, 0x0168 }, /*                      Utilde Ũ LATIN CAPITAL LETTER U WITH TILDE */
        { 0x03de, 0x016a }, /*                     Umacron Ū LATIN CAPITAL LETTER U WITH MACRON */
        { 0x03e0, 0x0101 }, /*                     amacron ā LATIN SMALL LETTER A WITH MACRON */
        { 0x03e7, 0x012f }, /*                     iogonek į LATIN SMALL LETTER I WITH OGONEK */
        { 0x03ec, 0x0117 }, /*                   eabovedot ė LATIN SMALL LETTER E WITH DOT ABOVE */
        { 0x03ef, 0x012b }, /*                     imacron ī LATIN SMALL LETTER I WITH MACRON */
        { 0x03f1, 0x0146 }, /*                    ncedilla ņ LATIN SMALL LETTER N WITH CEDILLA */
        { 0x03f2, 0x014d }, /*                     omacron ō LATIN SMALL LETTER O WITH MACRON */
        { 0x03f3, 0x0137 }, /*                    kcedilla ķ LATIN SMALL LETTER K WITH CEDILLA */
        { 0x03f9, 0x0173 }, /*                     uogonek ų LATIN SMALL LETTER U WITH OGONEK */
        { 0x03fd, 0x0169 }, /*                      utilde ũ LATIN SMALL LETTER U WITH TILDE */
        { 0x03fe, 0x016b }, /*                     umacron ū LATIN SMALL LETTER U WITH MACRON */
        { 0x047e, 0x203e }, /*                    overline ‾ OVERLINE */
        { 0x04a1, 0x3002 }, /*               kana_fullstop 。 IDEOGRAPHIC FULL STOP */
        { 0x04a2, 0x300c }, /*         kana_openingbracket 「 LEFT CORNER BRACKET */
        { 0x04a3, 0x300d }, /*         kana_closingbracket 」 RIGHT CORNER BRACKET */
        { 0x04a4, 0x3001 }, /*                  kana_comma 、 IDEOGRAPHIC COMMA */
        { 0x04a5, 0x30fb }, /*            kana_conjunctive ・ KATAKANA MIDDLE DOT */
        { 0x04a6, 0x30f2 }, /*                     kana_WO ヲ KATAKANA LETTER WO */
        { 0x04a7, 0x30a1 }, /*                      kana_a ァ KATAKANA LETTER SMALL A */
        { 0x04a8, 0x30a3 }, /*                      kana_i ィ KATAKANA LETTER SMALL I */
        { 0x04a9, 0x30a5 }, /*                      kana_u ゥ KATAKANA LETTER SMALL U */
        { 0x04aa, 0x30a7 }, /*                      kana_e ェ KATAKANA LETTER SMALL E */
        { 0x04ab, 0x30a9 }, /*                      kana_o ォ KATAKANA LETTER SMALL O */
        { 0x04ac, 0x30e3 }, /*                     kana_ya ャ KATAKANA LETTER SMALL YA */
        { 0x04ad, 0x30e5 }, /*                     kana_yu ュ KATAKANA LETTER SMALL YU */
        { 0x04ae, 0x30e7 }, /*                     kana_yo ョ KATAKANA LETTER SMALL YO */
        { 0x04af, 0x30c3 }, /*                    kana_tsu ッ KATAKANA LETTER SMALL TU */
        { 0x04b0, 0x30fc }, /*              prolongedsound ー KATAKANA-HIRAGANA PROLONGED SOUND MARK */
        { 0x04b1, 0x30a2 }, /*                      kana_A ア KATAKANA LETTER A */
        { 0x04b2, 0x30a4 }, /*                      kana_I イ KATAKANA LETTER I */
        { 0x04b3, 0x30a6 }, /*                      kana_U ウ KATAKANA LETTER U */
        { 0x04b4, 0x30a8 }, /*                      kana_E エ KATAKANA LETTER E */
        { 0x04b5, 0x30aa }, /*                      kana_O オ KATAKANA LETTER O */
        { 0x04b6, 0x30ab }, /*                     kana_KA カ KATAKANA LETTER KA */
        { 0x04b7, 0x30ad }, /*                     kana_KI キ KATAKANA LETTER KI */
        { 0x04b8, 0x30af }, /*                     kana_KU ク KATAKANA LETTER KU */
        { 0x04b9, 0x30b1 }, /*                     kana_KE ケ KATAKANA LETTER KE */
        { 0x04ba, 0x30b3 }, /*                     kana_KO コ KATAKANA LETTER KO */
        { 0x04bb, 0x30b5 }, /*                     kana_SA サ KATAKANA LETTER SA */
        { 0x04bc, 0x30b7 }, /*                    kana_SHI シ KATAKANA LETTER SI */
        { 0x04bd, 0x30b9 }, /*                     kana_SU ス KATAKANA LETTER SU */
        { 0x04be, 0x30bb }, /*                     kana_SE セ KATAKANA LETTER SE */
        { 0x04bf, 0x30bd }, /*                     kana_SO ソ KATAKANA LETTER SO */
        { 0x04c0, 0x30bf }, /*                     kana_TA タ KATAKANA LETTER TA */
        { 0x04c1, 0x30c1 }, /*                    kana_CHI チ KATAKANA LETTER TI */
        { 0x04c2, 0x30c4 }, /*                    kana_TSU ツ KATAKANA LETTER TU */
        { 0x04c3, 0x30c6 }, /*                     kana_TE テ KATAKANA LETTER TE */
        { 0x04c4, 0x30c8 }, /*                     kana_TO ト KATAKANA LETTER TO */
        { 0x04c5, 0x30ca }, /*                     kana_NA ナ KATAKANA LETTER NA */
        { 0x04c6, 0x30cb }, /*                     kana_NI ニ KATAKANA LETTER NI */
        { 0x04c7, 0x30cc }, /*                     kana_NU ヌ KATAKANA LETTER NU */
        { 0x04c8, 0x30cd }, /*                     kana_NE ネ KATAKANA LETTER NE */
        { 0x04c9, 0x30ce }, /*                     kana_NO ノ KATAKANA LETTER NO */
        { 0x04ca, 0x30cf }, /*                     kana_HA ハ KATAKANA LETTER HA */
        { 0x04cb, 0x30d2 }, /*                     kana_HI ヒ KATAKANA LETTER HI */
        { 0x04cc, 0x30d5 }, /*                     kana_FU フ KATAKANA LETTER HU */
        { 0x04cd, 0x30d8 }, /*                     kana_HE ヘ KATAKANA LETTER HE */
        { 0x04ce, 0x30db }, /*                     kana_HO ホ KATAKANA LETTER HO */
        { 0x04cf, 0x30de }, /*                     kana_MA マ KATAKANA LETTER MA */
        { 0x04d0, 0x30df }, /*                     kana_MI ミ KATAKANA LETTER MI */
        { 0x04d1, 0x30e0 }, /*                     kana_MU ム KATAKANA LETTER MU */
        { 0x04d2, 0x30e1 }, /*                     kana_ME メ KATAKANA LETTER ME */
        { 0x04d3, 0x30e2 }, /*                     kana_MO モ KATAKANA LETTER MO */
        { 0x04d4, 0x30e4 }, /*                     kana_YA ヤ KATAKANA LETTER YA */
        { 0x04d5, 0x30e6 }, /*                     kana_YU ユ KATAKANA LETTER YU */
        { 0x04d6, 0x30e8 }, /*                     kana_YO ヨ KATAKANA LETTER YO */
        { 0x04d7, 0x30e9 }, /*                     kana_RA ラ KATAKANA LETTER RA */
        { 0x04d8, 0x30ea }, /*                     kana_RI リ KATAKANA LETTER RI */
        { 0x04d9, 0x30eb }, /*                     kana_RU ル KATAKANA LETTER RU */
        { 0x04da, 0x30ec }, /*                     kana_RE レ KATAKANA LETTER RE */
        { 0x04db, 0x30ed }, /*                     kana_RO ロ KATAKANA LETTER RO */
        { 0x04dc, 0x30ef }, /*                     kana_WA ワ KATAKANA LETTER WA */
        { 0x04dd, 0x30f3 }, /*                      kana_N ン KATAKANA LETTER N */
        { 0x04de, 0x309b }, /*                 voicedsound ゛ KATAKANA-HIRAGANA VOICED SOUND MARK */
        { 0x04df, 0x309c }, /*             semivoicedsound ゜ KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK */
        { 0x05ac, 0x060c }, /*                Arabic_comma ، ARABIC COMMA */
        { 0x05bb, 0x061b }, /*            Arabic_semicolon ؛ ARABIC SEMICOLON */
        { 0x05bf, 0x061f }, /*        Arabic_question_mark ؟ ARABIC QUESTION MARK */
        { 0x05c1, 0x0621 }, /*                Arabic_hamza ء ARABIC LETTER HAMZA */
        { 0x05c2, 0x0622 }, /*          Arabic_maddaonalef آ ARABIC LETTER ALEF WITH MADDA ABOVE */
        { 0x05c3, 0x0623 }, /*          Arabic_hamzaonalef أ ARABIC LETTER ALEF WITH HAMZA ABOVE */
        { 0x05c4, 0x0624 }, /*           Arabic_hamzaonwaw ؤ ARABIC LETTER WAW WITH HAMZA ABOVE */
        { 0x05c5, 0x0625 }, /*       Arabic_hamzaunderalef إ ARABIC LETTER ALEF WITH HAMZA BELOW */
        { 0x05c6, 0x0626 }, /*           Arabic_hamzaonyeh ئ ARABIC LETTER YEH WITH HAMZA ABOVE */
        { 0x05c7, 0x0627 }, /*                 Arabic_alef ا ARABIC LETTER ALEF */
        { 0x05c8, 0x0628 }, /*                  Arabic_beh ب ARABIC LETTER BEH */
        { 0x05c9, 0x0629 }, /*           Arabic_tehmarbuta ة ARABIC LETTER TEH MARBUTA */
        { 0x05ca, 0x062a }, /*                  Arabic_teh ت ARABIC LETTER TEH */
        { 0x05cb, 0x062b }, /*                 Arabic_theh ث ARABIC LETTER THEH */
        { 0x05cc, 0x062c }, /*                 Arabic_jeem ج ARABIC LETTER JEEM */
        { 0x05cd, 0x062d }, /*                  Arabic_hah ح ARABIC LETTER HAH */
        { 0x05ce, 0x062e }, /*                 Arabic_khah خ ARABIC LETTER KHAH */
        { 0x05cf, 0x062f }, /*                  Arabic_dal د ARABIC LETTER DAL */
        { 0x05d0, 0x0630 }, /*                 Arabic_thal ذ ARABIC LETTER THAL */
        { 0x05d1, 0x0631 }, /*                   Arabic_ra ر ARABIC LETTER REH */
        { 0x05d2, 0x0632 }, /*                 Arabic_zain ز ARABIC LETTER ZAIN */
        { 0x05d3, 0x0633 }, /*                 Arabic_seen س ARABIC LETTER SEEN */
        { 0x05d4, 0x0634 }, /*                Arabic_sheen ش ARABIC LETTER SHEEN */
        { 0x05d5, 0x0635 }, /*                  Arabic_sad ص ARABIC LETTER SAD */
        { 0x05d6, 0x0636 }, /*                  Arabic_dad ض ARABIC LETTER DAD */
        { 0x05d7, 0x0637 }, /*                  Arabic_tah ط ARABIC LETTER TAH */
        { 0x05d8, 0x0638 }, /*                  Arabic_zah ظ ARABIC LETTER ZAH */
        { 0x05d9, 0x0639 }, /*                  Arabic_ain ع ARABIC LETTER AIN */
        { 0x05da, 0x063a }, /*                Arabic_ghain غ ARABIC LETTER GHAIN */
        { 0x05e0, 0x0640 }, /*              Arabic_tatweel ـ ARABIC TATWEEL */
        { 0x05e1, 0x0641 }, /*                  Arabic_feh ف ARABIC LETTER FEH */
        { 0x05e2, 0x0642 }, /*                  Arabic_qaf ق ARABIC LETTER QAF */
        { 0x05e3, 0x0643 }, /*                  Arabic_kaf ك ARABIC LETTER KAF */
        { 0x05e4, 0x0644 }, /*                  Arabic_lam ل ARABIC LETTER LAM */
        { 0x05e5, 0x0645 }, /*                 Arabic_meem م ARABIC LETTER MEEM */
        { 0x05e6, 0x0646 }, /*                 Arabic_noon ن ARABIC LETTER NOON */
        { 0x05e7, 0x0647 }, /*                   Arabic_ha ه ARABIC LETTER HEH */
        { 0x05e8, 0x0648 }, /*                  Arabic_waw و ARABIC LETTER WAW */
        { 0x05e9, 0x0649 }, /*          Arabic_alefmaksura ى ARABIC LETTER ALEF MAKSURA */
        { 0x05ea, 0x064a }, /*                  Arabic_yeh ي ARABIC LETTER YEH */
        { 0x05eb, 0x064b }, /*             Arabic_fathatan ً ARABIC FATHATAN */
        { 0x05ec, 0x064c }, /*             Arabic_dammatan ٌ ARABIC DAMMATAN */
        { 0x05ed, 0x064d }, /*             Arabic_kasratan ٍ ARABIC KASRATAN */
        { 0x05ee, 0x064e }, /*                Arabic_fatha َ ARABIC FATHA */
        { 0x05ef, 0x064f }, /*                Arabic_damma ُ ARABIC DAMMA */
        { 0x05f0, 0x0650 }, /*                Arabic_kasra ِ ARABIC KASRA */
        { 0x05f1, 0x0651 }, /*               Arabic_shadda ّ ARABIC SHADDA */
        { 0x05f2, 0x0652 }, /*                Arabic_sukun ْ ARABIC SUKUN */
        { 0x06a1, 0x0452 }, /*                 Serbian_dje ђ CYRILLIC SMALL LETTER DJE */
        { 0x06a2, 0x0453 }, /*               Macedonia_gje ѓ CYRILLIC SMALL LETTER GJE */
        { 0x06a3, 0x0451 }, /*                 Cyrillic_io ё CYRILLIC SMALL LETTER IO */
        { 0x06a4, 0x0454 }, /*                Ukrainian_ie є CYRILLIC SMALL LETTER UKRAINIAN IE */
        { 0x06a5, 0x0455 }, /*               Macedonia_dse ѕ CYRILLIC SMALL LETTER DZE */
        { 0x06a6, 0x0456 }, /*                 Ukrainian_i і CYRILLIC SMALL LETTER BYELORUSSIAN-UKRAINIAN I */
        { 0x06a7, 0x0457 }, /*                Ukrainian_yi ї CYRILLIC SMALL LETTER YI */
        { 0x06a8, 0x0458 }, /*                 Cyrillic_je ј CYRILLIC SMALL LETTER JE */
        { 0x06a9, 0x0459 }, /*                Cyrillic_lje љ CYRILLIC SMALL LETTER LJE */
        { 0x06aa, 0x045a }, /*                Cyrillic_nje њ CYRILLIC SMALL LETTER NJE */
        { 0x06ab, 0x045b }, /*                Serbian_tshe ћ CYRILLIC SMALL LETTER TSHE */
        { 0x06ac, 0x045c }, /*               Macedonia_kje ќ CYRILLIC SMALL LETTER KJE */
        { 0x06ad, 0x0491 }, /*   Ukrainian_ghe_with_upturn ґ CYRILLIC SMALL LETTER GHE WITH UPTURN */
        { 0x06ae, 0x045e }, /*         Byelorussian_shortu ў CYRILLIC SMALL LETTER SHORT U */
        { 0x06af, 0x045f }, /*               Cyrillic_dzhe џ CYRILLIC SMALL LETTER DZHE */
        { 0x06b0, 0x2116 }, /*                  numerosign № NUMERO SIGN */
        { 0x06b1, 0x0402 }, /*                 Serbian_DJE Ђ CYRILLIC CAPITAL LETTER DJE */
        { 0x06b2, 0x0403 }, /*               Macedonia_GJE Ѓ CYRILLIC CAPITAL LETTER GJE */
        { 0x06b3, 0x0401 }, /*                 Cyrillic_IO Ё CYRILLIC CAPITAL LETTER IO */
        { 0x06b4, 0x0404 }, /*                Ukrainian_IE Є CYRILLIC CAPITAL LETTER UKRAINIAN IE */
        { 0x06b5, 0x0405 }, /*               Macedonia_DSE Ѕ CYRILLIC CAPITAL LETTER DZE */
        { 0x06b6, 0x0406 }, /*                 Ukrainian_I І CYRILLIC CAPITAL LETTER BYELORUSSIAN-UKRAINIAN I */
        { 0x06b7, 0x0407 }, /*                Ukrainian_YI Ї CYRILLIC CAPITAL LETTER YI */
        { 0x06b8, 0x0408 }, /*                 Cyrillic_JE Ј CYRILLIC CAPITAL LETTER JE */
        { 0x06b9, 0x0409 }, /*                Cyrillic_LJE Љ CYRILLIC CAPITAL LETTER LJE */
        { 0x06ba, 0x040a }, /*                Cyrillic_NJE Њ CYRILLIC CAPITAL LETTER NJE */
        { 0x06bb, 0x040b }, /*                Serbian_TSHE Ћ CYRILLIC CAPITAL LETTER TSHE */
        { 0x06bc, 0x040c }, /*               Macedonia_KJE Ќ CYRILLIC CAPITAL LETTER KJE */
        { 0x06bd, 0x0490 }, /*   Ukrainian_GHE_WITH_UPTURN Ґ CYRILLIC CAPITAL LETTER GHE WITH UPTURN */
        { 0x06be, 0x040e }, /*         Byelorussian_SHORTU Ў CYRILLIC CAPITAL LETTER SHORT U */
        { 0x06bf, 0x040f }, /*               Cyrillic_DZHE Џ CYRILLIC CAPITAL LETTER DZHE */
        { 0x06c0, 0x044e }, /*                 Cyrillic_yu ю CYRILLIC SMALL LETTER YU */
        { 0x06c1, 0x0430 }, /*                  Cyrillic_a а CYRILLIC SMALL LETTER A */
        { 0x06c2, 0x0431 }, /*                 Cyrillic_be б CYRILLIC SMALL LETTER BE */
        { 0x06c3, 0x0446 }, /*                Cyrillic_tse ц CYRILLIC SMALL LETTER TSE */
        { 0x06c4, 0x0434 }, /*                 Cyrillic_de д CYRILLIC SMALL LETTER DE */
        { 0x06c5, 0x0435 }, /*                 Cyrillic_ie е CYRILLIC SMALL LETTER IE */
        { 0x06c6, 0x0444 }, /*                 Cyrillic_ef ф CYRILLIC SMALL LETTER EF */
        { 0x06c7, 0x0433 }, /*                Cyrillic_ghe г CYRILLIC SMALL LETTER GHE */
        { 0x06c8, 0x0445 }, /*                 Cyrillic_ha х CYRILLIC SMALL LETTER HA */
        { 0x06c9, 0x0438 }, /*                  Cyrillic_i и CYRILLIC SMALL LETTER I */
        { 0x06ca, 0x0439 }, /*             Cyrillic_shorti й CYRILLIC SMALL LETTER SHORT I */
        { 0x06cb, 0x043a }, /*                 Cyrillic_ka к CYRILLIC SMALL LETTER KA */
        { 0x06cc, 0x043b }, /*                 Cyrillic_el л CYRILLIC SMALL LETTER EL */
        { 0x06cd, 0x043c }, /*                 Cyrillic_em м CYRILLIC SMALL LETTER EM */
        { 0x06ce, 0x043d }, /*                 Cyrillic_en н CYRILLIC SMALL LETTER EN */
        { 0x06cf, 0x043e }, /*                  Cyrillic_o о CYRILLIC SMALL LETTER O */
        { 0x06d0, 0x043f }, /*                 Cyrillic_pe п CYRILLIC SMALL LETTER PE */
        { 0x06d1, 0x044f }, /*                 Cyrillic_ya я CYRILLIC SMALL LETTER YA */
        { 0x06d2, 0x0440 }, /*                 Cyrillic_er р CYRILLIC SMALL LETTER ER */
        { 0x06d3, 0x0441 }, /*                 Cyrillic_es с CYRILLIC SMALL LETTER ES */
        { 0x06d4, 0x0442 }, /*                 Cyrillic_te т CYRILLIC SMALL LETTER TE */
        { 0x06d5, 0x0443 }, /*                  Cyrillic_u у CYRILLIC SMALL LETTER U */
        { 0x06d6, 0x0436 }, /*                Cyrillic_zhe ж CYRILLIC SMALL LETTER ZHE */
        { 0x06d7, 0x0432 }, /*                 Cyrillic_ve в CYRILLIC SMALL LETTER VE */
        { 0x06d8, 0x044c }, /*           Cyrillic_softsign ь CYRILLIC SMALL LETTER SOFT SIGN */
        { 0x06d9, 0x044b }, /*               Cyrillic_yeru ы CYRILLIC SMALL LETTER YERU */
        { 0x06da, 0x0437 }, /*                 Cyrillic_ze з CYRILLIC SMALL LETTER ZE */
        { 0x06db, 0x0448 }, /*                Cyrillic_sha ш CYRILLIC SMALL LETTER SHA */
        { 0x06dc, 0x044d }, /*                  Cyrillic_e э CYRILLIC SMALL LETTER E */
        { 0x06dd, 0x0449 }, /*              Cyrillic_shcha щ CYRILLIC SMALL LETTER SHCHA */
        { 0x06de, 0x0447 }, /*                Cyrillic_che ч CYRILLIC SMALL LETTER CHE */
        { 0x06df, 0x044a }, /*           Cyrillic_hardsign ъ CYRILLIC SMALL LETTER HARD SIGN */
        { 0x06e0, 0x042e }, /*                 Cyrillic_YU Ю CYRILLIC CAPITAL LETTER YU */
        { 0x06e1, 0x0410 }, /*                  Cyrillic_A А CYRILLIC CAPITAL LETTER A */
        { 0x06e2, 0x0411 }, /*                 Cyrillic_BE Б CYRILLIC CAPITAL LETTER BE */
        { 0x06e3, 0x0426 }, /*                Cyrillic_TSE Ц CYRILLIC CAPITAL LETTER TSE */
        { 0x06e4, 0x0414 }, /*                 Cyrillic_DE Д CYRILLIC CAPITAL LETTER DE */
        { 0x06e5, 0x0415 }, /*                 Cyrillic_IE Е CYRILLIC CAPITAL LETTER IE */
        { 0x06e6, 0x0424 }, /*                 Cyrillic_EF Ф CYRILLIC CAPITAL LETTER EF */
        { 0x06e7, 0x0413 }, /*                Cyrillic_GHE Г CYRILLIC CAPITAL LETTER GHE */
        { 0x06e8, 0x0425 }, /*                 Cyrillic_HA Х CYRILLIC CAPITAL LETTER HA */
        { 0x06e9, 0x0418 }, /*                  Cyrillic_I И CYRILLIC CAPITAL LETTER I */
        { 0x06ea, 0x0419 }, /*             Cyrillic_SHORTI Й CYRILLIC CAPITAL LETTER SHORT I */
        { 0x06eb, 0x041a }, /*                 Cyrillic_KA К CYRILLIC CAPITAL LETTER KA */
        { 0x06ec, 0x041b }, /*                 Cyrillic_EL Л CYRILLIC CAPITAL LETTER EL */
        { 0x06ed, 0x041c }, /*                 Cyrillic_EM М CYRILLIC CAPITAL LETTER EM */
        { 0x06ee, 0x041d }, /*                 Cyrillic_EN Н CYRILLIC CAPITAL LETTER EN */
        { 0x06ef, 0x041e }, /*                  Cyrillic_O О CYRILLIC CAPITAL LETTER O */
        { 0x06f0, 0x041f }, /*                 Cyrillic_PE П CYRILLIC CAPITAL LETTER PE */
        { 0x06f1, 0x042f }, /*                 Cyrillic_YA Я CYRILLIC CAPITAL LETTER YA */
        { 0x06f2, 0x0420 }, /*                 Cyrillic_ER Р CYRILLIC CAPITAL LETTER ER */
        { 0x06f3, 0x0421 }, /*                 Cyrillic_ES С CYRILLIC CAPITAL LETTER ES */
        { 0x06f4, 0x0422 }, /*                 Cyrillic_TE Т CYRILLIC CAPITAL LETTER TE */
        { 0x06f5, 0x0423 }, /*                  Cyrillic_U У CYRILLIC CAPITAL LETTER U */
        { 0x06f6, 0x0416 }, /*                Cyrillic_ZHE Ж CYRILLIC CAPITAL LETTER ZHE */
        { 0x06f7, 0x0412 }, /*                 Cyrillic_VE В CYRILLIC CAPITAL LETTER VE */
        { 0x06f8, 0x042c }, /*           Cyrillic_SOFTSIGN Ь CYRILLIC CAPITAL LETTER SOFT SIGN */
        { 0x06f9, 0x042b }, /*               Cyrillic_YERU Ы CYRILLIC CAPITAL LETTER YERU */
        { 0x06fa, 0x0417 }, /*                 Cyrillic_ZE З CYRILLIC CAPITAL LETTER ZE */
        { 0x06fb, 0x0428 }, /*                Cyrillic_SHA Ш CYRILLIC CAPITAL LETTER SHA */
        { 0x06fc, 0x042d }, /*                  Cyrillic_E Э CYRILLIC CAPITAL LETTER E */
        { 0x06fd, 0x0429 }, /*              Cyrillic_SHCHA Щ CYRILLIC CAPITAL LETTER SHCHA */
        { 0x06fe, 0x0427 }, /*                Cyrillic_CHE Ч CYRILLIC CAPITAL LETTER CHE */
        { 0x06ff, 0x042a }, /*           Cyrillic_HARDSIGN Ъ CYRILLIC CAPITAL LETTER HARD SIGN */
        { 0x07a1, 0x0386 }, /*           Greek_ALPHAaccent Ά GREEK CAPITAL LETTER ALPHA WITH TONOS */
        { 0x07a2, 0x0388 }, /*         Greek_EPSILONaccent Έ GREEK CAPITAL LETTER EPSILON WITH TONOS */
        { 0x07a3, 0x0389 }, /*             Greek_ETAaccent Ή GREEK CAPITAL LETTER ETA WITH TONOS */
        { 0x07a4, 0x038a }, /*            Greek_IOTAaccent Ί GREEK CAPITAL LETTER IOTA WITH TONOS */
        { 0x07a5, 0x03aa }, /*          Greek_IOTAdieresis Ϊ GREEK CAPITAL LETTER IOTA WITH DIALYTIKA */
        { 0x07a7, 0x038c }, /*         Greek_OMICRONaccent Ό GREEK CAPITAL LETTER OMICRON WITH TONOS */
        { 0x07a8, 0x038e }, /*         Greek_UPSILONaccent Ύ GREEK CAPITAL LETTER UPSILON WITH TONOS */
        { 0x07a9, 0x03ab }, /*       Greek_UPSILONdieresis Ϋ GREEK CAPITAL LETTER UPSILON WITH DIALYTIKA */
        { 0x07ab, 0x038f }, /*           Greek_OMEGAaccent Ώ GREEK CAPITAL LETTER OMEGA WITH TONOS */
        { 0x07ae, 0x0385 }, /*        Greek_accentdieresis ΅ GREEK DIALYTIKA TONOS */
        { 0x07af, 0x2015 }, /*              Greek_horizbar ― HORIZONTAL BAR */
        { 0x07b1, 0x03ac }, /*           Greek_alphaaccent ά GREEK SMALL LETTER ALPHA WITH TONOS */
        { 0x07b2, 0x03ad }, /*         Greek_epsilonaccent έ GREEK SMALL LETTER EPSILON WITH TONOS */
        { 0x07b3, 0x03ae }, /*             Greek_etaaccent ή GREEK SMALL LETTER ETA WITH TONOS */
        { 0x07b4, 0x03af }, /*            Greek_iotaaccent ί GREEK SMALL LETTER IOTA WITH TONOS */
        { 0x07b5, 0x03ca }, /*          Greek_iotadieresis ϊ GREEK SMALL LETTER IOTA WITH DIALYTIKA */
        { 0x07b6, 0x0390 }, /*    Greek_iotaaccentdieresis ΐ GREEK SMALL LETTER IOTA WITH DIALYTIKA AND TONOS */
        { 0x07b7, 0x03cc }, /*         Greek_omicronaccent ό GREEK SMALL LETTER OMICRON WITH TONOS */
        { 0x07b8, 0x03cd }, /*         Greek_upsilonaccent ύ GREEK SMALL LETTER UPSILON WITH TONOS */
        { 0x07b9, 0x03cb }, /*       Greek_upsilondieresis ϋ GREEK SMALL LETTER UPSILON WITH DIALYTIKA */
        { 0x07ba, 0x03b0 }, /* Greek_upsilonaccentdieresis ΰ GREEK SMALL LETTER UPSILON WITH DIALYTIKA AND TONOS */
        { 0x07bb, 0x03ce }, /*           Greek_omegaaccent ώ GREEK SMALL LETTER OMEGA WITH TONOS */
        { 0x07c1, 0x0391 }, /*                 Greek_ALPHA Α GREEK CAPITAL LETTER ALPHA */
        { 0x07c2, 0x0392 }, /*                  Greek_BETA Β GREEK CAPITAL LETTER BETA */
        { 0x07c3, 0x0393 }, /*                 Greek_GAMMA Γ GREEK CAPITAL LETTER GAMMA */
        { 0x07c4, 0x0394 }, /*                 Greek_DELTA Δ GREEK CAPITAL LETTER DELTA */
        { 0x07c5, 0x0395 }, /*               Greek_EPSILON Ε GREEK CAPITAL LETTER EPSILON */
        { 0x07c6, 0x0396 }, /*                  Greek_ZETA Ζ GREEK CAPITAL LETTER ZETA */
        { 0x07c7, 0x0397 }, /*                   Greek_ETA Η GREEK CAPITAL LETTER ETA */
        { 0x07c8, 0x0398 }, /*                 Greek_THETA Θ GREEK CAPITAL LETTER THETA */
        { 0x07c9, 0x0399 }, /*                  Greek_IOTA Ι GREEK CAPITAL LETTER IOTA */
        { 0x07ca, 0x039a }, /*                 Greek_KAPPA Κ GREEK CAPITAL LETTER KAPPA */
        { 0x07cb, 0x039b }, /*                Greek_LAMBDA Λ GREEK CAPITAL LETTER LAMDA */
        { 0x07cc, 0x039c }, /*                    Greek_MU Μ GREEK CAPITAL LETTER MU */
        { 0x07cd, 0x039d }, /*                    Greek_NU Ν GREEK CAPITAL LETTER NU */
        { 0x07ce, 0x039e }, /*                    Greek_XI Ξ GREEK CAPITAL LETTER XI */
        { 0x07cf, 0x039f }, /*               Greek_OMICRON Ο GREEK CAPITAL LETTER OMICRON */
        { 0x07d0, 0x03a0 }, /*                    Greek_PI Π GREEK CAPITAL LETTER PI */
        { 0x07d1, 0x03a1 }, /*                   Greek_RHO Ρ GREEK CAPITAL LETTER RHO */
        { 0x07d2, 0x03a3 }, /*                 Greek_SIGMA Σ GREEK CAPITAL LETTER SIGMA */
        { 0x07d4, 0x03a4 }, /*                   Greek_TAU Τ GREEK CAPITAL LETTER TAU */
        { 0x07d5, 0x03a5 }, /*               Greek_UPSILON Υ GREEK CAPITAL LETTER UPSILON */
        { 0x07d6, 0x03a6 }, /*                   Greek_PHI Φ GREEK CAPITAL LETTER PHI */
        { 0x07d7, 0x03a7 }, /*                   Greek_CHI Χ GREEK CAPITAL LETTER CHI */
        { 0x07d8, 0x03a8 }, /*                   Greek_PSI Ψ GREEK CAPITAL LETTER PSI */
        { 0x07d9, 0x03a9 }, /*                 Greek_OMEGA Ω GREEK CAPITAL LETTER OMEGA */
        { 0x07e1, 0x03b1 }, /*                 Greek_alpha α GREEK SMALL LETTER ALPHA */
        { 0x07e2, 0x03b2 }, /*                  Greek_beta β GREEK SMALL LETTER BETA */
        { 0x07e3, 0x03b3 }, /*                 Greek_gamma γ GREEK SMALL LETTER GAMMA */
        { 0x07e4, 0x03b4 }, /*                 Greek_delta δ GREEK SMALL LETTER DELTA */
        { 0x07e5, 0x03b5 }, /*               Greek_epsilon ε GREEK SMALL LETTER EPSILON */
        { 0x07e6, 0x03b6 }, /*                  Greek_zeta ζ GREEK SMALL LETTER ZETA */
        { 0x07e7, 0x03b7 }, /*                   Greek_eta η GREEK SMALL LETTER ETA */
        { 0x07e8, 0x03b8 }, /*                 Greek_theta θ GREEK SMALL LETTER THETA */
        { 0x07e9, 0x03b9 }, /*                  Greek_iota ι GREEK SMALL LETTER IOTA */
        { 0x07ea, 0x03ba }, /*                 Greek_kappa κ GREEK SMALL LETTER KAPPA */
        { 0x07eb, 0x03bb }, /*                Greek_lambda λ GREEK SMALL LETTER LAMDA */
        { 0x07ec, 0x03bc }, /*                    Greek_mu μ GREEK SMALL LETTER MU */
        { 0x07ed, 0x03bd }, /*                    Greek_nu ν GREEK SMALL LETTER NU */
        { 0x07ee, 0x03be }, /*                    Greek_xi ξ GREEK SMALL LETTER XI */
        { 0x07ef, 0x03bf }, /*               Greek_omicron ο GREEK SMALL LETTER OMICRON */
        { 0x07f0, 0x03c0 }, /*                    Greek_pi π GREEK SMALL LETTER PI */
        { 0x07f1, 0x03c1 }, /*                   Greek_rho ρ GREEK SMALL LETTER RHO */
        { 0x07f2, 0x03c3 }, /*                 Greek_sigma σ GREEK SMALL LETTER SIGMA */
        { 0x07f3, 0x03c2 }, /*       Greek_finalsmallsigma ς GREEK SMALL LETTER FINAL SIGMA */
        { 0x07f4, 0x03c4 }, /*                   Greek_tau τ GREEK SMALL LETTER TAU */
        { 0x07f5, 0x03c5 }, /*               Greek_upsilon υ GREEK SMALL LETTER UPSILON */
        { 0x07f6, 0x03c6 }, /*                   Greek_phi φ GREEK SMALL LETTER PHI */
        { 0x07f7, 0x03c7 }, /*                   Greek_chi χ GREEK SMALL LETTER CHI */
        { 0x07f8, 0x03c8 }, /*                   Greek_psi ψ GREEK SMALL LETTER PSI */
        { 0x07f9, 0x03c9 }, /*                 Greek_omega ω GREEK SMALL LETTER OMEGA */
        { 0x08a4, 0x2320 }, /*                 topintegral ⌠ TOP HALF INTEGRAL */
        { 0x08a5, 0x2321 }, /*                 botintegral ⌡ BOTTOM HALF INTEGRAL */
        { 0x08a6, 0x2502 }, /*               vertconnector │ BOX DRAWINGS LIGHT VERTICAL */
        { 0x08bc, 0x2264 }, /*               lessthanequal ≤ LESS-THAN OR EQUAL TO */
        { 0x08bd, 0x2260 }, /*                    notequal ≠ NOT EQUAL TO */
        { 0x08be, 0x2265 }, /*            greaterthanequal ≥ GREATER-THAN OR EQUAL TO */
        { 0x08bf, 0x222b }, /*                    integral ∫ INTEGRAL */
        { 0x08c0, 0x2234 }, /*                   therefore ∴ THEREFORE */
        { 0x08c1, 0x221d }, /*                   variation ∝ PROPORTIONAL TO */
        { 0x08c2, 0x221e }, /*                    infinity ∞ INFINITY */
        { 0x08c5, 0x2207 }, /*                       nabla ∇ NABLA */
        { 0x08c8, 0x2245 }, /*                 approximate ≅ APPROXIMATELY EQUAL TO */
        { 0x08cd, 0x21d4 }, /*                    ifonlyif ⇔ LEFT RIGHT DOUBLE ARROW */
        { 0x08ce, 0x21d2 }, /*                     implies ⇒ RIGHTWARDS DOUBLE ARROW */
        { 0x08cf, 0x2261 }, /*                   identical ≡ IDENTICAL TO */
        { 0x08d6, 0x221a }, /*                     radical √ SQUARE ROOT */
        { 0x08da, 0x2282 }, /*                  includedin ⊂ SUBSET OF */
        { 0x08db, 0x2283 }, /*                    includes ⊃ SUPERSET OF */
        { 0x08dc, 0x2229 }, /*                intersection ∩ INTERSECTION */
        { 0x08dd, 0x222a }, /*                       union ∪ UNION */
        { 0x08de, 0x2227 }, /*                  logicaland ∧ LOGICAL AND */
        { 0x08df, 0x2228 }, /*                   logicalor ∨ LOGICAL OR */
        { 0x08ef, 0x2202 }, /*           partialderivative ∂ PARTIAL DIFFERENTIAL */
        { 0x08f6, 0x0192 }, /*                    function ƒ LATIN SMALL LETTER F WITH HOOK */
        { 0x08fb, 0x2190 }, /*                   leftarrow ← LEFTWARDS ARROW */
        { 0x08fc, 0x2191 }, /*                     uparrow ↑ UPWARDS ARROW */
        { 0x08fd, 0x2192 }, /*                  rightarrow → RIGHTWARDS ARROW */
        { 0x08fe, 0x2193 }, /*                   downarrow ↓ DOWNWARDS ARROW */
        { 0x09df, 0x2422 }, /*                       blank ␢ BLANK SYMBOL */
        { 0x09e0, 0x25c6 }, /*                soliddiamond ◆ BLACK DIAMOND */
        { 0x09e1, 0x2592 }, /*                checkerboard ▒ MEDIUM SHADE */
        { 0x09e2, 0x2409 }, /*                          ht ␉ SYMBOL FOR HORIZONTAL TABULATION */
        { 0x09e3, 0x240c }, /*                          ff ␌ SYMBOL FOR FORM FEED */
        { 0x09e4, 0x240d }, /*                          cr ␍ SYMBOL FOR CARRIAGE RETURN */
        { 0x09e5, 0x240a }, /*                          lf ␊ SYMBOL FOR LINE FEED */
        { 0x09e8, 0x2424 }, /*                          nl ␤ SYMBOL FOR NEWLINE */
        { 0x09e9, 0x240b }, /*                          vt ␋ SYMBOL FOR VERTICAL TABULATION */
        { 0x09ea, 0x2518 }, /*              lowrightcorner ┘ BOX DRAWINGS LIGHT UP AND LEFT */
        { 0x09eb, 0x2510 }, /*               uprightcorner ┐ BOX DRAWINGS LIGHT DOWN AND LEFT */
        { 0x09ec, 0x250c }, /*                upleftcorner ┌ BOX DRAWINGS LIGHT DOWN AND RIGHT */
        { 0x09ed, 0x2514 }, /*               lowleftcorner └ BOX DRAWINGS LIGHT UP AND RIGHT */
        { 0x09ee, 0x253c }, /*               crossinglines ┼ BOX DRAWINGS LIGHT VERTICAL AND HORIZONTAL */
        { 0x09f1, 0x2500 }, /*              horizlinescan5 ─ BOX DRAWINGS LIGHT HORIZONTAL */
        { 0x09f4, 0x251c }, /*                       leftt ├ BOX DRAWINGS LIGHT VERTICAL AND RIGHT */
        { 0x09f5, 0x2524 }, /*                      rightt ┤ BOX DRAWINGS LIGHT VERTICAL AND LEFT */
        { 0x09f6, 0x2534 }, /*                        bott ┴ BOX DRAWINGS LIGHT UP AND HORIZONTAL */
        { 0x09f7, 0x252c }, /*                        topt ┬ BOX DRAWINGS LIGHT DOWN AND HORIZONTAL */
        { 0x09f8, 0x2502 }, /*                     vertbar │ BOX DRAWINGS LIGHT VERTICAL */
        { 0x0aa1, 0x2003 }, /*                     emspace   EM SPACE */
        { 0x0aa2, 0x2002 }, /*                     enspace   EN SPACE */
        { 0x0aa3, 0x2004 }, /*                    em3space   THREE-PER-EM SPACE */
        { 0x0aa4, 0x2005 }, /*                    em4space   FOUR-PER-EM SPACE */
        { 0x0aa5, 0x2007 }, /*                  digitspace   FIGURE SPACE */
        { 0x0aa6, 0x2008 }, /*                  punctspace   PUNCTUATION SPACE */
        { 0x0aa7, 0x2009 }, /*                   thinspace   THIN SPACE */
        { 0x0aa8, 0x200a }, /*                   hairspace   HAIR SPACE */
        { 0x0aa9, 0x2014 }, /*                      emdash — EM DASH */
        { 0x0aaa, 0x2013 }, /*                      endash – EN DASH */
        { 0x0aae, 0x2026 }, /*                    ellipsis … HORIZONTAL ELLIPSIS */
        { 0x0ab0, 0x2153 }, /*                    onethird ⅓ VULGAR FRACTION ONE THIRD */
        { 0x0ab1, 0x2154 }, /*                   twothirds ⅔ VULGAR FRACTION TWO THIRDS */
        { 0x0ab2, 0x2155 }, /*                    onefifth ⅕ VULGAR FRACTION ONE FIFTH */
        { 0x0ab3, 0x2156 }, /*                   twofifths ⅖ VULGAR FRACTION TWO FIFTHS */
        { 0x0ab4, 0x2157 }, /*                 threefifths ⅗ VULGAR FRACTION THREE FIFTHS */
        { 0x0ab5, 0x2158 }, /*                  fourfifths ⅘ VULGAR FRACTION FOUR FIFTHS */
        { 0x0ab6, 0x2159 }, /*                    onesixth ⅙ VULGAR FRACTION ONE SIXTH */
        { 0x0ab7, 0x215a }, /*                  fivesixths ⅚ VULGAR FRACTION FIVE SIXTHS */
        { 0x0ab8, 0x2105 }, /*                      careof ℅ CARE OF */
        { 0x0abb, 0x2012 }, /*                     figdash ‒ FIGURE DASH */
        { 0x0abc, 0x2329 }, /*            leftanglebracket 〈 LEFT-POINTING ANGLE BRACKET */
        { 0x0abd, 0x002e }, /*                decimalpoint . FULL STOP */
        { 0x0abe, 0x232a }, /*           rightanglebracket 〉 RIGHT-POINTING ANGLE BRACKET */
        { 0x0ac3, 0x215b }, /*                   oneeighth ⅛ VULGAR FRACTION ONE EIGHTH */
        { 0x0ac4, 0x215c }, /*                threeeighths ⅜ VULGAR FRACTION THREE EIGHTHS */
        { 0x0ac5, 0x215d }, /*                 fiveeighths ⅝ VULGAR FRACTION FIVE EIGHTHS */
        { 0x0ac6, 0x215e }, /*                seveneighths ⅞ VULGAR FRACTION SEVEN EIGHTHS */
        { 0x0ac9, 0x2122 }, /*                   trademark ™ TRADE MARK SIGN */
        { 0x0aca, 0x2613 }, /*               signaturemark ☓ SALTIRE */
        { 0x0acc, 0x25c1 }, /*            leftopentriangle ◁ WHITE LEFT-POINTING TRIANGLE */
        { 0x0acd, 0x25b7 }, /*           rightopentriangle ▷ WHITE RIGHT-POINTING TRIANGLE */
        { 0x0ace, 0x25cb }, /*                emopencircle ○ WHITE CIRCLE */
        { 0x0acf, 0x25a1 }, /*             emopenrectangle □ WHITE SQUARE */
        { 0x0ad0, 0x2018 }, /*         leftsinglequotemark ‘ LEFT SINGLE QUOTATION MARK */
        { 0x0ad1, 0x2019 }, /*        rightsinglequotemark ’ RIGHT SINGLE QUOTATION MARK */
        { 0x0ad2, 0x201c }, /*         leftdoublequotemark “ LEFT DOUBLE QUOTATION MARK */
        { 0x0ad3, 0x201d }, /*        rightdoublequotemark ” RIGHT DOUBLE QUOTATION MARK */
        { 0x0ad4, 0x211e }, /*                prescription ℞ PRESCRIPTION TAKE */
        { 0x0ad6, 0x2032 }, /*                     minutes ′ PRIME */
        { 0x0ad7, 0x2033 }, /*                     seconds ″ DOUBLE PRIME */
        { 0x0ad9, 0x271d }, /*                  latincross ✝ LATIN CROSS */
        { 0x0adb, 0x25ac }, /*            filledrectbullet ▬ BLACK RECTANGLE */
        { 0x0adc, 0x25c0 }, /*         filledlefttribullet ◀ BLACK LEFT-POINTING TRIANGLE */
        { 0x0add, 0x25b6 }, /*        filledrighttribullet ▶ BLACK RIGHT-POINTING TRIANGLE */
        { 0x0ade, 0x25cf }, /*              emfilledcircle ● BLACK CIRCLE */
        { 0x0adf, 0x25a0 }, /*                emfilledrect ■ BLACK SQUARE */
        { 0x0ae0, 0x25e6 }, /*            enopencircbullet ◦ WHITE BULLET */
        { 0x0ae1, 0x25ab }, /*          enopensquarebullet ▫ WHITE SMALL SQUARE */
        { 0x0ae2, 0x25ad }, /*              openrectbullet ▭ WHITE RECTANGLE */
        { 0x0ae3, 0x25b3 }, /*             opentribulletup △ WHITE UP-POINTING TRIANGLE */
        { 0x0ae4, 0x25bd }, /*           opentribulletdown ▽ WHITE DOWN-POINTING TRIANGLE */
        { 0x0ae5, 0x2606 }, /*                    openstar ☆ WHITE STAR */
        { 0x0ae6, 0x2022 }, /*          enfilledcircbullet • BULLET */
        { 0x0ae7, 0x25aa }, /*            enfilledsqbullet ▪ BLACK SMALL SQUARE */
        { 0x0ae8, 0x25b2 }, /*           filledtribulletup ▲ BLACK UP-POINTING TRIANGLE */
        { 0x0ae9, 0x25bc }, /*         filledtribulletdown ▼ BLACK DOWN-POINTING TRIANGLE */
        { 0x0aea, 0x261c }, /*                 leftpointer ☜ WHITE LEFT POINTING INDEX */
        { 0x0aeb, 0x261e }, /*                rightpointer ☞ WHITE RIGHT POINTING INDEX */
        { 0x0aec, 0x2663 }, /*                        club ♣ BLACK CLUB SUIT */
        { 0x0aed, 0x2666 }, /*                     diamond ♦ BLACK DIAMOND SUIT */
        { 0x0aee, 0x2665 }, /*                       heart ♥ BLACK HEART SUIT */
        { 0x0af0, 0x2720 }, /*                maltesecross ✠ MALTESE CROSS */
        { 0x0af1, 0x2020 }, /*                      dagger † DAGGER */
        { 0x0af2, 0x2021 }, /*                doubledagger ‡ DOUBLE DAGGER */
        { 0x0af3, 0x2713 }, /*                   checkmark ✓ CHECK MARK */
        { 0x0af4, 0x2717 }, /*                 ballotcross ✗ BALLOT X */
        { 0x0af5, 0x266f }, /*                musicalsharp ♯ MUSIC SHARP SIGN */
        { 0x0af6, 0x266d }, /*                 musicalflat ♭ MUSIC FLAT SIGN */
        { 0x0af7, 0x2642 }, /*                  malesymbol ♂ MALE SIGN */
        { 0x0af8, 0x2640 }, /*                femalesymbol ♀ FEMALE SIGN */
        { 0x0af9, 0x260e }, /*                   telephone ☎ BLACK TELEPHONE */
        { 0x0afa, 0x2315 }, /*           telephonerecorder ⌕ TELEPHONE RECORDER */
        { 0x0afb, 0x2117 }, /*         phonographcopyright ℗ SOUND RECORDING COPYRIGHT */
        { 0x0afc, 0x2038 }, /*                       caret ‸ CARET */
        { 0x0afd, 0x201a }, /*          singlelowquotemark ‚ SINGLE LOW-9 QUOTATION MARK */
        { 0x0afe, 0x201e }, /*          doublelowquotemark „ DOUBLE LOW-9 QUOTATION MARK */
        { 0x0ba3, 0x003c }, /*                   leftcaret < LESS-THAN SIGN */
        { 0x0ba6, 0x003e }, /*                  rightcaret > GREATER-THAN SIGN */
        { 0x0ba8, 0x2228 }, /*                   downcaret ∨ LOGICAL OR */
        { 0x0ba9, 0x2227 }, /*                     upcaret ∧ LOGICAL AND */
        { 0x0bc0, 0x00af }, /*                     overbar ¯ MACRON */
        { 0x0bc2, 0x22a4 }, /*                    downtack ⊤ DOWN TACK */
        { 0x0bc3, 0x2229 }, /*                      upshoe ∩ INTERSECTION */
        { 0x0bc4, 0x230a }, /*                   downstile ⌊ LEFT FLOOR */
        { 0x0bc6, 0x005f }, /*                    underbar _ LOW LINE */
        { 0x0bca, 0x2218 }, /*                         jot ∘ RING OPERATOR */
        { 0x0bcc, 0x2395 }, /*                        quad ⎕ APL FUNCTIONAL SYMBOL QUAD (Unicode 3.0) */
        { 0x0bce, 0x22a5 }, /*                      uptack ⊥ UP TACK */
        { 0x0bcf, 0x25cb }, /*                      circle ○ WHITE CIRCLE */
        { 0x0bd3, 0x2308 }, /*                     upstile ⌈ LEFT CEILING */
        { 0x0bd6, 0x222a }, /*                    downshoe ∪ UNION */
        { 0x0bd8, 0x2283 }, /*                   rightshoe ⊃ SUPERSET OF */
        { 0x0bda, 0x2282 }, /*                    leftshoe ⊂ SUBSET OF */
        { 0x0bdc, 0x22a3 }, /*                    lefttack ⊣ LEFT TACK */
        { 0x0bfc, 0x22a2 }, /*                   righttack ⊢ RIGHT TACK */
        { 0x0cdf, 0x2017 }, /*        hebrew_doublelowline ‗ DOUBLE LOW LINE */
        { 0x0ce0, 0x05d0 }, /*                hebrew_aleph א HEBREW LETTER ALEF */
        { 0x0ce1, 0x05d1 }, /*                  hebrew_bet ב HEBREW LETTER BET */
        { 0x0ce2, 0x05d2 }, /*                hebrew_gimel ג HEBREW LETTER GIMEL */
        { 0x0ce3, 0x05d3 }, /*                hebrew_dalet ד HEBREW LETTER DALET */
        { 0x0ce4, 0x05d4 }, /*                   hebrew_he ה HEBREW LETTER HE */
        { 0x0ce5, 0x05d5 }, /*                  hebrew_waw ו HEBREW LETTER VAV */
        { 0x0ce6, 0x05d6 }, /*                 hebrew_zain ז HEBREW LETTER ZAYIN */
        { 0x0ce7, 0x05d7 }, /*                 hebrew_chet ח HEBREW LETTER HET */
        { 0x0ce8, 0x05d8 }, /*                  hebrew_tet ט HEBREW LETTER TET */
        { 0x0ce9, 0x05d9 }, /*                  hebrew_yod י HEBREW LETTER YOD */
        { 0x0cea, 0x05da }, /*            hebrew_finalkaph ך HEBREW LETTER FINAL KAF */
        { 0x0ceb, 0x05db }, /*                 hebrew_kaph כ HEBREW LETTER KAF */
        { 0x0cec, 0x05dc }, /*                hebrew_lamed ל HEBREW LETTER LAMED */
        { 0x0ced, 0x05dd }, /*             hebrew_finalmem ם HEBREW LETTER FINAL MEM */
        { 0x0cee, 0x05de }, /*                  hebrew_mem מ HEBREW LETTER MEM */
        { 0x0cef, 0x05df }, /*             hebrew_finalnun ן HEBREW LETTER FINAL NUN */
        { 0x0cf0, 0x05e0 }, /*                  hebrew_nun נ HEBREW LETTER NUN */
        { 0x0cf1, 0x05e1 }, /*               hebrew_samech ס HEBREW LETTER SAMEKH */
        { 0x0cf2, 0x05e2 }, /*                 hebrew_ayin ע HEBREW LETTER AYIN */
        { 0x0cf3, 0x05e3 }, /*              hebrew_finalpe ף HEBREW LETTER FINAL PE */
        { 0x0cf4, 0x05e4 }, /*                   hebrew_pe פ HEBREW LETTER PE */
        { 0x0cf5, 0x05e5 }, /*            hebrew_finalzade ץ HEBREW LETTER FINAL TSADI */
        { 0x0cf6, 0x05e6 }, /*                 hebrew_zade צ HEBREW LETTER TSADI */
        { 0x0cf7, 0x05e7 }, /*                 hebrew_qoph ק HEBREW LETTER QOF */
        { 0x0cf8, 0x05e8 }, /*                 hebrew_resh ר HEBREW LETTER RESH */
        { 0x0cf9, 0x05e9 }, /*                 hebrew_shin ש HEBREW LETTER SHIN */
        { 0x0cfa, 0x05ea }, /*                  hebrew_taw ת HEBREW LETTER TAV */
        { 0x0da1, 0x0e01 }, /*                  Thai_kokai ก THAI CHARACTER KO KAI */
        { 0x0da2, 0x0e02 }, /*                Thai_khokhai ข THAI CHARACTER KHO KHAI */
        { 0x0da3, 0x0e03 }, /*               Thai_khokhuat ฃ THAI CHARACTER KHO KHUAT */
        { 0x0da4, 0x0e04 }, /*               Thai_khokhwai ค THAI CHARACTER KHO KHWAI */
        { 0x0da5, 0x0e05 }, /*                Thai_khokhon ฅ THAI CHARACTER KHO KHON */
        { 0x0da6, 0x0e06 }, /*             Thai_khorakhang ฆ THAI CHARACTER KHO RAKHANG */
        { 0x0da7, 0x0e07 }, /*                 Thai_ngongu ง THAI CHARACTER NGO NGU */
        { 0x0da8, 0x0e08 }, /*                Thai_chochan จ THAI CHARACTER CHO CHAN */
        { 0x0da9, 0x0e09 }, /*               Thai_choching ฉ THAI CHARACTER CHO CHING */
        { 0x0daa, 0x0e0a }, /*               Thai_chochang ช THAI CHARACTER CHO CHANG */
        { 0x0dab, 0x0e0b }, /*                   Thai_soso ซ THAI CHARACTER SO SO */
        { 0x0dac, 0x0e0c }, /*                Thai_chochoe ฌ THAI CHARACTER CHO CHOE */
        { 0x0dad, 0x0e0d }, /*                 Thai_yoying ญ THAI CHARACTER YO YING */
        { 0x0dae, 0x0e0e }, /*                Thai_dochada ฎ THAI CHARACTER DO CHADA */
        { 0x0daf, 0x0e0f }, /*                Thai_topatak ฏ THAI CHARACTER TO PATAK */
        { 0x0db0, 0x0e10 }, /*                Thai_thothan ฐ THAI CHARACTER THO THAN */
        { 0x0db1, 0x0e11 }, /*          Thai_thonangmontho ฑ THAI CHARACTER THO NANGMONTHO */
        { 0x0db2, 0x0e12 }, /*             Thai_thophuthao ฒ THAI CHARACTER THO PHUTHAO */
        { 0x0db3, 0x0e13 }, /*                  Thai_nonen ณ THAI CHARACTER NO NEN */
        { 0x0db4, 0x0e14 }, /*                  Thai_dodek ด THAI CHARACTER DO DEK */
        { 0x0db5, 0x0e15 }, /*                  Thai_totao ต THAI CHARACTER TO TAO */
        { 0x0db6, 0x0e16 }, /*               Thai_thothung ถ THAI CHARACTER THO THUNG */
        { 0x0db7, 0x0e17 }, /*              Thai_thothahan ท THAI CHARACTER THO THAHAN */
        { 0x0db8, 0x0e18 }, /*               Thai_thothong ธ THAI CHARACTER THO THONG */
        { 0x0db9, 0x0e19 }, /*                   Thai_nonu น THAI CHARACTER NO NU */
        { 0x0dba, 0x0e1a }, /*               Thai_bobaimai บ THAI CHARACTER BO BAIMAI */
        { 0x0dbb, 0x0e1b }, /*                  Thai_popla ป THAI CHARACTER PO PLA */
        { 0x0dbc, 0x0e1c }, /*               Thai_phophung ผ THAI CHARACTER PHO PHUNG */
        { 0x0dbd, 0x0e1d }, /*                   Thai_fofa ฝ THAI CHARACTER FO FA */
        { 0x0dbe, 0x0e1e }, /*                Thai_phophan พ THAI CHARACTER PHO PHAN */
        { 0x0dbf, 0x0e1f }, /*                  Thai_fofan ฟ THAI CHARACTER FO FAN */
        { 0x0dc0, 0x0e20 }, /*             Thai_phosamphao ภ THAI CHARACTER PHO SAMPHAO */
        { 0x0dc1, 0x0e21 }, /*                   Thai_moma ม THAI CHARACTER MO MA */
        { 0x0dc2, 0x0e22 }, /*                  Thai_yoyak ย THAI CHARACTER YO YAK */
        { 0x0dc3, 0x0e23 }, /*                  Thai_rorua ร THAI CHARACTER RO RUA */
        { 0x0dc4, 0x0e24 }, /*                     Thai_ru ฤ THAI CHARACTER RU */
        { 0x0dc5, 0x0e25 }, /*                 Thai_loling ล THAI CHARACTER LO LING */
        { 0x0dc6, 0x0e26 }, /*                     Thai_lu ฦ THAI CHARACTER LU */
        { 0x0dc7, 0x0e27 }, /*                 Thai_wowaen ว THAI CHARACTER WO WAEN */
        { 0x0dc8, 0x0e28 }, /*                 Thai_sosala ศ THAI CHARACTER SO SALA */
        { 0x0dc9, 0x0e29 }, /*                 Thai_sorusi ษ THAI CHARACTER SO RUSI */
        { 0x0dca, 0x0e2a }, /*                  Thai_sosua ส THAI CHARACTER SO SUA */
        { 0x0dcb, 0x0e2b }, /*                  Thai_hohip ห THAI CHARACTER HO HIP */
        { 0x0dcc, 0x0e2c }, /*                Thai_lochula ฬ THAI CHARACTER LO CHULA */
        { 0x0dcd, 0x0e2d }, /*                   Thai_oang อ THAI CHARACTER O ANG */
        { 0x0dce, 0x0e2e }, /*               Thai_honokhuk ฮ THAI CHARACTER HO NOKHUK */
        { 0x0dcf, 0x0e2f }, /*              Thai_paiyannoi ฯ THAI CHARACTER PAIYANNOI */
        { 0x0dd0, 0x0e30 }, /*                  Thai_saraa ะ THAI CHARACTER SARA A */
        { 0x0dd1, 0x0e31 }, /*             Thai_maihanakat ั THAI CHARACTER MAI HAN-AKAT */
        { 0x0dd2, 0x0e32 }, /*                 Thai_saraaa า THAI CHARACTER SARA AA */
        { 0x0dd3, 0x0e33 }, /*                 Thai_saraam ำ THAI CHARACTER SARA AM */
        { 0x0dd4, 0x0e34 }, /*                  Thai_sarai ิ THAI CHARACTER SARA I */
        { 0x0dd5, 0x0e35 }, /*                 Thai_saraii ี THAI CHARACTER SARA II */
        { 0x0dd6, 0x0e36 }, /*                 Thai_saraue ึ THAI CHARACTER SARA UE */
        { 0x0dd7, 0x0e37 }, /*                Thai_sarauee ื THAI CHARACTER SARA UEE */
        { 0x0dd8, 0x0e38 }, /*                  Thai_sarau ุ THAI CHARACTER SARA U */
        { 0x0dd9, 0x0e39 }, /*                 Thai_sarauu ู THAI CHARACTER SARA UU */
        { 0x0dda, 0x0e3a }, /*                Thai_phinthu ฺ THAI CHARACTER PHINTHU */
        { 0x0dde, 0x0e3e }, /*      Thai_maihanakat_maitho ฾ ??? */
        { 0x0ddf, 0x0e3f }, /*                   Thai_baht ฿ THAI CURRENCY SYMBOL BAHT */
        { 0x0de0, 0x0e40 }, /*                  Thai_sarae เ THAI CHARACTER SARA E */
        { 0x0de1, 0x0e41 }, /*                 Thai_saraae แ THAI CHARACTER SARA AE */
        { 0x0de2, 0x0e42 }, /*                  Thai_sarao โ THAI CHARACTER SARA O */
        { 0x0de3, 0x0e43 }, /*          Thai_saraaimaimuan ใ THAI CHARACTER SARA AI MAIMUAN */
        { 0x0de4, 0x0e44 }, /*         Thai_saraaimaimalai ไ THAI CHARACTER SARA AI MAIMALAI */
        { 0x0de5, 0x0e45 }, /*            Thai_lakkhangyao ๅ THAI CHARACTER LAKKHANGYAO */
        { 0x0de6, 0x0e46 }, /*               Thai_maiyamok ๆ THAI CHARACTER MAIYAMOK */
        { 0x0de7, 0x0e47 }, /*              Thai_maitaikhu ็ THAI CHARACTER MAITAIKHU */
        { 0x0de8, 0x0e48 }, /*                  Thai_maiek ่ THAI CHARACTER MAI EK */
        { 0x0de9, 0x0e49 }, /*                 Thai_maitho ้ THAI CHARACTER MAI THO */
        { 0x0dea, 0x0e4a }, /*                 Thai_maitri ๊ THAI CHARACTER MAI TRI */
        { 0x0deb, 0x0e4b }, /*            Thai_maichattawa ๋ THAI CHARACTER MAI CHATTAWA */
        { 0x0dec, 0x0e4c }, /*            Thai_thanthakhat ์ THAI CHARACTER THANTHAKHAT */
        { 0x0ded, 0x0e4d }, /*               Thai_nikhahit ํ THAI CHARACTER NIKHAHIT */
        { 0x0df0, 0x0e50 }, /*                 Thai_leksun ๐ THAI DIGIT ZERO */
        { 0x0df1, 0x0e51 }, /*                Thai_leknung ๑ THAI DIGIT ONE */
        { 0x0df2, 0x0e52 }, /*                Thai_leksong ๒ THAI DIGIT TWO */
        { 0x0df3, 0x0e53 }, /*                 Thai_leksam ๓ THAI DIGIT THREE */
        { 0x0df4, 0x0e54 }, /*                  Thai_leksi ๔ THAI DIGIT FOUR */
        { 0x0df5, 0x0e55 }, /*                  Thai_lekha ๕ THAI DIGIT FIVE */
        { 0x0df6, 0x0e56 }, /*                 Thai_lekhok ๖ THAI DIGIT SIX */
        { 0x0df7, 0x0e57 }, /*                Thai_lekchet ๗ THAI DIGIT SEVEN */
        { 0x0df8, 0x0e58 }, /*                Thai_lekpaet ๘ THAI DIGIT EIGHT */
        { 0x0df9, 0x0e59 }, /*                 Thai_lekkao ๙ THAI DIGIT NINE */
        { 0x0ea1, 0x3131 }, /*               Hangul_Kiyeog ㄱ HANGUL LETTER KIYEOK */
        { 0x0ea2, 0x3132 }, /*          Hangul_SsangKiyeog ㄲ HANGUL LETTER SSANGKIYEOK */
        { 0x0ea3, 0x3133 }, /*           Hangul_KiyeogSios ㄳ HANGUL LETTER KIYEOK-SIOS */
        { 0x0ea4, 0x3134 }, /*                Hangul_Nieun ㄴ HANGUL LETTER NIEUN */
        { 0x0ea5, 0x3135 }, /*           Hangul_NieunJieuj ㄵ HANGUL LETTER NIEUN-CIEUC */
        { 0x0ea6, 0x3136 }, /*           Hangul_NieunHieuh ㄶ HANGUL LETTER NIEUN-HIEUH */
        { 0x0ea7, 0x3137 }, /*               Hangul_Dikeud ㄷ HANGUL LETTER TIKEUT */
        { 0x0ea8, 0x3138 }, /*          Hangul_SsangDikeud ㄸ HANGUL LETTER SSANGTIKEUT */
        { 0x0ea9, 0x3139 }, /*                Hangul_Rieul ㄹ HANGUL LETTER RIEUL */
        { 0x0eaa, 0x313a }, /*          Hangul_RieulKiyeog ㄺ HANGUL LETTER RIEUL-KIYEOK */
        { 0x0eab, 0x313b }, /*           Hangul_RieulMieum ㄻ HANGUL LETTER RIEUL-MIEUM */
        { 0x0eac, 0x313c }, /*           Hangul_RieulPieub ㄼ HANGUL LETTER RIEUL-PIEUP */
        { 0x0ead, 0x313d }, /*            Hangul_RieulSios ㄽ HANGUL LETTER RIEUL-SIOS */
        { 0x0eae, 0x313e }, /*           Hangul_RieulTieut ㄾ HANGUL LETTER RIEUL-THIEUTH */
        { 0x0eaf, 0x313f }, /*          Hangul_RieulPhieuf ㄿ HANGUL LETTER RIEUL-PHIEUPH */
        { 0x0eb0, 0x3140 }, /*           Hangul_RieulHieuh ㅀ HANGUL LETTER RIEUL-HIEUH */
        { 0x0eb1, 0x3141 }, /*                Hangul_Mieum ㅁ HANGUL LETTER MIEUM */
        { 0x0eb2, 0x3142 }, /*                Hangul_Pieub ㅂ HANGUL LETTER PIEUP */
        { 0x0eb3, 0x3143 }, /*           Hangul_SsangPieub ㅃ HANGUL LETTER SSANGPIEUP */
        { 0x0eb4, 0x3144 }, /*            Hangul_PieubSios ㅄ HANGUL LETTER PIEUP-SIOS */
        { 0x0eb5, 0x3145 }, /*                 Hangul_Sios ㅅ HANGUL LETTER SIOS */
        { 0x0eb6, 0x3146 }, /*            Hangul_SsangSios ㅆ HANGUL LETTER SSANGSIOS */
        { 0x0eb7, 0x3147 }, /*                Hangul_Ieung ㅇ HANGUL LETTER IEUNG */
        { 0x0eb8, 0x3148 }, /*                Hangul_Jieuj ㅈ HANGUL LETTER CIEUC */
        { 0x0eb9, 0x3149 }, /*           Hangul_SsangJieuj ㅉ HANGUL LETTER SSANGCIEUC */
        { 0x0eba, 0x314a }, /*                Hangul_Cieuc ㅊ HANGUL LETTER CHIEUCH */
        { 0x0ebb, 0x314b }, /*               Hangul_Khieuq ㅋ HANGUL LETTER KHIEUKH */
        { 0x0ebc, 0x314c }, /*                Hangul_Tieut ㅌ HANGUL LETTER THIEUTH */
        { 0x0ebd, 0x314d }, /*               Hangul_Phieuf ㅍ HANGUL LETTER PHIEUPH */
        { 0x0ebe, 0x314e }, /*                Hangul_Hieuh ㅎ HANGUL LETTER HIEUH */
        { 0x0ebf, 0x314f }, /*                    Hangul_A ㅏ HANGUL LETTER A */
        { 0x0ec0, 0x3150 }, /*                   Hangul_AE ㅐ HANGUL LETTER AE */
        { 0x0ec1, 0x3151 }, /*                   Hangul_YA ㅑ HANGUL LETTER YA */
        { 0x0ec2, 0x3152 }, /*                  Hangul_YAE ㅒ HANGUL LETTER YAE */
        { 0x0ec3, 0x3153 }, /*                   Hangul_EO ㅓ HANGUL LETTER EO */
        { 0x0ec4, 0x3154 }, /*                    Hangul_E ㅔ HANGUL LETTER E */
        { 0x0ec5, 0x3155 }, /*                  Hangul_YEO ㅕ HANGUL LETTER YEO */
        { 0x0ec6, 0x3156 }, /*                   Hangul_YE ㅖ HANGUL LETTER YE */
        { 0x0ec7, 0x3157 }, /*                    Hangul_O ㅗ HANGUL LETTER O */
        { 0x0ec8, 0x3158 }, /*                   Hangul_WA ㅘ HANGUL LETTER WA */
        { 0x0ec9, 0x3159 }, /*                  Hangul_WAE ㅙ HANGUL LETTER WAE */
        { 0x0eca, 0x315a }, /*                   Hangul_OE ㅚ HANGUL LETTER OE */
        { 0x0ecb, 0x315b }, /*                   Hangul_YO ㅛ HANGUL LETTER YO */
        { 0x0ecc, 0x315c }, /*                    Hangul_U ㅜ HANGUL LETTER U */
        { 0x0ecd, 0x315d }, /*                  Hangul_WEO ㅝ HANGUL LETTER WEO */
        { 0x0ece, 0x315e }, /*                   Hangul_WE ㅞ HANGUL LETTER WE */
        { 0x0ecf, 0x315f }, /*                   Hangul_WI ㅟ HANGUL LETTER WI */
        { 0x0ed0, 0x3160 }, /*                   Hangul_YU ㅠ HANGUL LETTER YU */
        { 0x0ed1, 0x3161 }, /*                   Hangul_EU ㅡ HANGUL LETTER EU */
        { 0x0ed2, 0x3162 }, /*                   Hangul_YI ㅢ HANGUL LETTER YI */
        { 0x0ed3, 0x3163 }, /*                    Hangul_I ㅣ HANGUL LETTER I */
        { 0x0ed4, 0x11a8 }, /*             Hangul_J_Kiyeog ᆨ HANGUL JONGSEONG KIYEOK */
        { 0x0ed5, 0x11a9 }, /*        Hangul_J_SsangKiyeog ᆩ HANGUL JONGSEONG SSANGKIYEOK */
        { 0x0ed6, 0x11aa }, /*         Hangul_J_KiyeogSios ᆪ HANGUL JONGSEONG KIYEOK-SIOS */
        { 0x0ed7, 0x11ab }, /*              Hangul_J_Nieun ᆫ HANGUL JONGSEONG NIEUN */
        { 0x0ed8, 0x11ac }, /*         Hangul_J_NieunJieuj ᆬ HANGUL JONGSEONG NIEUN-CIEUC */
        { 0x0ed9, 0x11ad }, /*         Hangul_J_NieunHieuh ᆭ HANGUL JONGSEONG NIEUN-HIEUH */
        { 0x0eda, 0x11ae }, /*             Hangul_J_Dikeud ᆮ HANGUL JONGSEONG TIKEUT */
        { 0x0edb, 0x11af }, /*              Hangul_J_Rieul ᆯ HANGUL JONGSEONG RIEUL */
        { 0x0edc, 0x11b0 }, /*        Hangul_J_RieulKiyeog ᆰ HANGUL JONGSEONG RIEUL-KIYEOK */
        { 0x0edd, 0x11b1 }, /*         Hangul_J_RieulMieum ᆱ HANGUL JONGSEONG RIEUL-MIEUM */
        { 0x0ede, 0x11b2 }, /*         Hangul_J_RieulPieub ᆲ HANGUL JONGSEONG RIEUL-PIEUP */
        { 0x0edf, 0x11b3 }, /*          Hangul_J_RieulSios ᆳ HANGUL JONGSEONG RIEUL-SIOS */
        { 0x0ee0, 0x11b4 }, /*         Hangul_J_RieulTieut ᆴ HANGUL JONGSEONG RIEUL-THIEUTH */
        { 0x0ee1, 0x11b5 }, /*        Hangul_J_RieulPhieuf ᆵ HANGUL JONGSEONG RIEUL-PHIEUPH */
        { 0x0ee2, 0x11b6 }, /*         Hangul_J_RieulHieuh ᆶ HANGUL JONGSEONG RIEUL-HIEUH */
        { 0x0ee3, 0x11b7 }, /*              Hangul_J_Mieum ᆷ HANGUL JONGSEONG MIEUM */
        { 0x0ee4, 0x11b8 }, /*              Hangul_J_Pieub ᆸ HANGUL JONGSEONG PIEUP */
        { 0x0ee5, 0x11b9 }, /*          Hangul_J_PieubSios ᆹ HANGUL JONGSEONG PIEUP-SIOS */
        { 0x0ee6, 0x11ba }, /*               Hangul_J_Sios ᆺ HANGUL JONGSEONG SIOS */
        { 0x0ee7, 0x11bb }, /*          Hangul_J_SsangSios ᆻ HANGUL JONGSEONG SSANGSIOS */
        { 0x0ee8, 0x11bc }, /*              Hangul_J_Ieung ᆼ HANGUL JONGSEONG IEUNG */
        { 0x0ee9, 0x11bd }, /*              Hangul_J_Jieuj ᆽ HANGUL JONGSEONG CIEUC */
        { 0x0eea, 0x11be }, /*              Hangul_J_Cieuc ᆾ HANGUL JONGSEONG CHIEUCH */
        { 0x0eeb, 0x11bf }, /*             Hangul_J_Khieuq ᆿ HANGUL JONGSEONG KHIEUKH */
        { 0x0eec, 0x11c0 }, /*              Hangul_J_Tieut ᇀ HANGUL JONGSEONG THIEUTH */
        { 0x0eed, 0x11c1 }, /*             Hangul_J_Phieuf ᇁ HANGUL JONGSEONG PHIEUPH */
        { 0x0eee, 0x11c2 }, /*              Hangul_J_Hieuh ᇂ HANGUL JONGSEONG HIEUH */
        { 0x0eef, 0x316d }, /*     Hangul_RieulYeorinHieuh ㅭ HANGUL LETTER RIEUL-YEORINHIEUH */
        { 0x0ef0, 0x3171 }, /*    Hangul_SunkyeongeumMieum ㅱ HANGUL LETTER KAPYEOUNMIEUM */
        { 0x0ef1, 0x3178 }, /*    Hangul_SunkyeongeumPieub ㅸ HANGUL LETTER KAPYEOUNPIEUP */
        { 0x0ef2, 0x317f }, /*              Hangul_PanSios ㅿ HANGUL LETTER PANSIOS */
        { 0x0ef4, 0x3184 }, /*   Hangul_SunkyeongeumPhieuf ㆄ HANGUL LETTER KAPYEOUNPHIEUPH */
        { 0x0ef5, 0x3186 }, /*          Hangul_YeorinHieuh ㆆ HANGUL LETTER YEORINHIEUH */
        { 0x0ef6, 0x318d }, /*                Hangul_AraeA ㆍ HANGUL LETTER ARAEA */
        { 0x0ef7, 0x318e }, /*               Hangul_AraeAE ㆎ HANGUL LETTER ARAEAE */
        { 0x0ef8, 0x11eb }, /*            Hangul_J_PanSios ᇫ HANGUL JONGSEONG PANSIOS */
        { 0x0efa, 0x11f9 }, /*        Hangul_J_YeorinHieuh ᇹ HANGUL JONGSEONG YEORINHIEUH */
        { 0x0eff, 0x20a9 }, /*                  Korean_Won ₩ WON SIGN */
        { 0x13bc, 0x0152 }, /*                          OE Œ LATIN CAPITAL LIGATURE OE */
        { 0x13bd, 0x0153 }, /*                          oe œ LATIN SMALL LIGATURE OE */
        { 0x13be, 0x0178 }, /*                  Ydiaeresis Ÿ LATIN CAPITAL LETTER Y WITH DIAERESIS */
        { 0x20a0, 0x20a0 }, /*                     EcuSign ₠ EURO-CURRENCY SIGN */
        { 0x20a1, 0x20a1 }, /*                   ColonSign ₡ COLON SIGN */
        { 0x20a2, 0x20a2 }, /*                CruzeiroSign ₢ CRUZEIRO SIGN */
        { 0x20a3, 0x20a3 }, /*                  FFrancSign ₣ FRENCH FRANC SIGN */
        { 0x20a4, 0x20a4 }, /*                    LiraSign ₤ LIRA SIGN */
        { 0x20a5, 0x20a5 }, /*                    MillSign ₥ MILL SIGN */
        { 0x20a6, 0x20a6 }, /*                   NairaSign ₦ NAIRA SIGN */
        { 0x20a7, 0x20a7 }, /*                  PesetaSign ₧ PESETA SIGN */
        { 0x20a8, 0x20a8 }, /*                   RupeeSign ₨ RUPEE SIGN */
        { 0x20a9, 0x20a9 }, /*                     WonSign ₩ WON SIGN */
        { 0x20aa, 0x20aa }, /*               NewSheqelSign ₪ NEW SHEQEL SIGN */
        { 0x20ab, 0x20ab }, /*                    DongSign ₫ DONG SIGN */
        { 0x20ac, 0x20ac }, /*                    EuroSign € EURO SIGN */
        { 0xFF80, ' ' },    /* Space */
        { 0xFFAA, '*' },    /* Multiply */
        { 0xFFAB, '+' },    /* Add */
        { 0xFFAC, ',' },    /* Separator */
        { 0xFFAD, '-' },    /* Subtract */
        { 0xFFAE, '.' },    /* Decimal */
        { 0xFFAF, '/' },    /* Divide */
        { 0xFFB0, '0' },    /* 0 */
        { 0xFFB1, '1' },    /* 1 */
        { 0xFFB2, '2' },    /* 2 */
        { 0xFFB3, '3' },    /* 3 */
        { 0xFFB4, '4' },    /* 4 */
        { 0xFFB5, '5' },    /* 5 */
        { 0xFFB6, '6' },    /* 6 */
        { 0xFFB7, '7' },    /* 7 */
        { 0xFFB8, '8' },    /* 8 */
        { 0xFFB9, '9' },    /* 9 */
        { 0xFFBD, '=' },    /* Equal */
    };

    private static Maia.Core.Map<global::Xcb.Keysym, Maia.Key> s_Keysyms = null;

    internal static unichar
    keysym_to_unicode (global::Xcb.Keysym inKeysym)
    {
        int min = 0;
        int max = c_KeysymTab.length - 1;
        int mid;

        if ((inKeysym >= 0x0020 && inKeysym <= 0x007e) || (inKeysym >= 0x00a0 && inKeysym <= 0x00ff))
            return inKeysym;

        if ((inKeysym & 0xff000000) == 0x01000000)
            return inKeysym & 0x00ffffff;

        while (max >= min)
        {
            mid = (min + max) / 2;
            if (c_KeysymTab[mid].keysym < inKeysym)
                min = mid + 1;
            else if (c_KeysymTab[mid].keysym > inKeysym)
                max = mid - 1;
            else
                return c_KeysymTab[mid].ucs;
        }

        return 0;
    }

    internal static Maia.Key
    convert_xcb_keysym_to_key (global::Xcb.Keysym inKey)
    {
        if (s_Keysyms == null)
        {
            s_Keysyms = new Maia.Core.Map<global::Xcb.Keysym, Maia.Key> ();

            s_Keysyms[global::Xcb.KeySym.VoidSymbol] = Maia.Key.VoidSymbol;
            s_Keysyms[global::Xcb.KeySym.BackSpace] = Maia.Key.BackSpace;
            s_Keysyms[global::Xcb.KeySym.Tab] = Maia.Key.Tab;
            s_Keysyms[global::Xcb.KeySym.Linefeed] = Maia.Key.Linefeed;
            s_Keysyms[global::Xcb.KeySym.Clear] = Maia.Key.Clear;
            s_Keysyms[global::Xcb.KeySym.Return] = Maia.Key.Return;
            s_Keysyms[global::Xcb.KeySym.Pause] = Maia.Key.Pause;
            s_Keysyms[global::Xcb.KeySym.Scroll_Lock] = Maia.Key.Scroll_Lock;
            s_Keysyms[global::Xcb.KeySym.Sys_Req] = Maia.Key.Sys_Req;
            s_Keysyms[global::Xcb.KeySym.Escape] = Maia.Key.Escape;
            s_Keysyms[global::Xcb.KeySym.Delete] = Maia.Key.Delete;
            s_Keysyms[global::Xcb.KeySym.Multi_key] = Maia.Key.Multi_key;
            s_Keysyms[global::Xcb.KeySym.Codeinput] = Maia.Key.Codeinput;
            s_Keysyms[global::Xcb.KeySym.MultipleCandidate] = Maia.Key.MultipleCandidate;
            s_Keysyms[global::Xcb.KeySym.PreviousCandidate] = Maia.Key.PreviousCandidate;
            s_Keysyms[global::Xcb.KeySym.Kanji] = Maia.Key.Kanji;
            s_Keysyms[global::Xcb.KeySym.Muhenkan] = Maia.Key.Muhenkan;
            s_Keysyms[global::Xcb.KeySym.Henkan_Mode] = Maia.Key.Henkan_Mode;
            s_Keysyms[global::Xcb.KeySym.Henkan] = Maia.Key.Henkan;
            s_Keysyms[global::Xcb.KeySym.Romaji] = Maia.Key.Romaji;
            s_Keysyms[global::Xcb.KeySym.Hiragana] = Maia.Key.Hiragana;
            s_Keysyms[global::Xcb.KeySym.Katakana] = Maia.Key.Katakana;
            s_Keysyms[global::Xcb.KeySym.Hiragana_Katakana] = Maia.Key.Hiragana_Katakana;
            s_Keysyms[global::Xcb.KeySym.Zenkaku] = Maia.Key.Zenkaku;
            s_Keysyms[global::Xcb.KeySym.Hankaku] = Maia.Key.Hankaku;
            s_Keysyms[global::Xcb.KeySym.Zenkaku_Hankaku] = Maia.Key.Zenkaku_Hankaku;
            s_Keysyms[global::Xcb.KeySym.Touroku] = Maia.Key.Touroku;
            s_Keysyms[global::Xcb.KeySym.Massyo] = Maia.Key.Massyo;
            s_Keysyms[global::Xcb.KeySym.Kana_Lock] = Maia.Key.Kana_Lock;
            s_Keysyms[global::Xcb.KeySym.Kana_Shift] = Maia.Key.Kana_Shift;
            s_Keysyms[global::Xcb.KeySym.Eisu_Shift] = Maia.Key.Eisu_Shift;
            s_Keysyms[global::Xcb.KeySym.Eisu_toggle] = Maia.Key.Eisu_toggle;
            s_Keysyms[global::Xcb.KeySym.Kanji_Bangou] = Maia.Key.Kanji_Bangou;
            s_Keysyms[global::Xcb.KeySym.Zen_Koho] = Maia.Key.Zen_Koho;
            s_Keysyms[global::Xcb.KeySym.Mae_Koho] = Maia.Key.Mae_Koho;
            s_Keysyms[global::Xcb.KeySym.Home] = Maia.Key.Home;
            s_Keysyms[global::Xcb.KeySym.Left] = Maia.Key.Left;
            s_Keysyms[global::Xcb.KeySym.Up] = Maia.Key.Up;
            s_Keysyms[global::Xcb.KeySym.Right] = Maia.Key.Right;
            s_Keysyms[global::Xcb.KeySym.Down] = Maia.Key.Down;
            s_Keysyms[global::Xcb.KeySym.Prior] = Maia.Key.Prior;
            s_Keysyms[global::Xcb.KeySym.Page_Up] = Maia.Key.Page_Up;
            s_Keysyms[global::Xcb.KeySym.Next] = Maia.Key.Next;
            s_Keysyms[global::Xcb.KeySym.Page_Down] = Maia.Key.Page_Down;
            s_Keysyms[global::Xcb.KeySym.End] = Maia.Key.End;
            s_Keysyms[global::Xcb.KeySym.Begin] = Maia.Key.Begin;
            s_Keysyms[global::Xcb.KeySym.Select] = Maia.Key.Select;
            s_Keysyms[global::Xcb.KeySym.Print] = Maia.Key.Print;
            s_Keysyms[global::Xcb.KeySym.Execute] = Maia.Key.Execute;
            s_Keysyms[global::Xcb.KeySym.Insert] = Maia.Key.Insert;
            s_Keysyms[global::Xcb.KeySym.Undo] = Maia.Key.Undo;
            s_Keysyms[global::Xcb.KeySym.Redo] = Maia.Key.Redo;
            s_Keysyms[global::Xcb.KeySym.Menu] = Maia.Key.Menu;
            s_Keysyms[global::Xcb.KeySym.Find] = Maia.Key.Find;
            s_Keysyms[global::Xcb.KeySym.Cancel] = Maia.Key.Cancel;
            s_Keysyms[global::Xcb.KeySym.Help] = Maia.Key.Help;
            s_Keysyms[global::Xcb.KeySym.Break] = Maia.Key.Break;
            s_Keysyms[global::Xcb.KeySym.Mode_switch] = Maia.Key.Mode_switch;
            s_Keysyms[global::Xcb.KeySym.script_switch] = Maia.Key.script_switch;
            s_Keysyms[global::Xcb.KeySym.Num_Lock] = Maia.Key.Num_Lock;
            s_Keysyms[global::Xcb.KeySym.KP_Space] = Maia.Key.KP_Space;
            s_Keysyms[global::Xcb.KeySym.KP_Tab] = Maia.Key.KP_Tab;
            s_Keysyms[global::Xcb.KeySym.KP_Enter] = Maia.Key.KP_Enter;
            s_Keysyms[global::Xcb.KeySym.KP_F1] = Maia.Key.KP_F1;
            s_Keysyms[global::Xcb.KeySym.KP_F2] = Maia.Key.KP_F2;
            s_Keysyms[global::Xcb.KeySym.KP_F3] = Maia.Key.KP_F3;
            s_Keysyms[global::Xcb.KeySym.KP_F4] = Maia.Key.KP_F4;
            s_Keysyms[global::Xcb.KeySym.KP_Home] = Maia.Key.KP_Home;
            s_Keysyms[global::Xcb.KeySym.KP_Left] = Maia.Key.KP_Left;
            s_Keysyms[global::Xcb.KeySym.KP_Up] = Maia.Key.KP_Up;
            s_Keysyms[global::Xcb.KeySym.KP_Right] = Maia.Key.KP_Right;
            s_Keysyms[global::Xcb.KeySym.KP_Down] = Maia.Key.KP_Down;
            s_Keysyms[global::Xcb.KeySym.KP_Prior] = Maia.Key.KP_Prior;
            s_Keysyms[global::Xcb.KeySym.KP_Page_Up] = Maia.Key.KP_Page_Up;
            s_Keysyms[global::Xcb.KeySym.KP_Next] = Maia.Key.KP_Next;
            s_Keysyms[global::Xcb.KeySym.KP_Page_Down] = Maia.Key.KP_Page_Down;
            s_Keysyms[global::Xcb.KeySym.KP_End] = Maia.Key.KP_End;
            s_Keysyms[global::Xcb.KeySym.KP_Begin] = Maia.Key.KP_Begin;
            s_Keysyms[global::Xcb.KeySym.KP_Insert] = Maia.Key.KP_Insert;
            s_Keysyms[global::Xcb.KeySym.KP_Delete] = Maia.Key.KP_Delete;
            s_Keysyms[global::Xcb.KeySym.KP_Equal] = Maia.Key.KP_Equal;
            s_Keysyms[global::Xcb.KeySym.KP_Multiply] = Maia.Key.KP_Multiply;
            s_Keysyms[global::Xcb.KeySym.KP_Add] = Maia.Key.KP_Add;
            s_Keysyms[global::Xcb.KeySym.KP_Separator] = Maia.Key.KP_Separator;
            s_Keysyms[global::Xcb.KeySym.KP_Subtract] = Maia.Key.KP_Subtract;
            s_Keysyms[global::Xcb.KeySym.KP_Decimal] = Maia.Key.KP_Decimal;
            s_Keysyms[global::Xcb.KeySym.KP_Divide] = Maia.Key.KP_Divide;
            s_Keysyms[global::Xcb.KeySym.KP_0] = Maia.Key.KP_0;
            s_Keysyms[global::Xcb.KeySym.KP_1] = Maia.Key.KP_1;
            s_Keysyms[global::Xcb.KeySym.KP_2] = Maia.Key.KP_2;
            s_Keysyms[global::Xcb.KeySym.KP_3] = Maia.Key.KP_3;
            s_Keysyms[global::Xcb.KeySym.KP_4] = Maia.Key.KP_4;
            s_Keysyms[global::Xcb.KeySym.KP_5] = Maia.Key.KP_5;
            s_Keysyms[global::Xcb.KeySym.KP_6] = Maia.Key.KP_6;
            s_Keysyms[global::Xcb.KeySym.KP_7] = Maia.Key.KP_7;
            s_Keysyms[global::Xcb.KeySym.KP_8] = Maia.Key.KP_8;
            s_Keysyms[global::Xcb.KeySym.KP_9] = Maia.Key.KP_9;
            s_Keysyms[global::Xcb.KeySym.F1] = Maia.Key.F1;
            s_Keysyms[global::Xcb.KeySym.F2] = Maia.Key.F2;
            s_Keysyms[global::Xcb.KeySym.F3] = Maia.Key.F3;
            s_Keysyms[global::Xcb.KeySym.F4] = Maia.Key.F4;
            s_Keysyms[global::Xcb.KeySym.F5] = Maia.Key.F5;
            s_Keysyms[global::Xcb.KeySym.F6] = Maia.Key.F6;
            s_Keysyms[global::Xcb.KeySym.F7] = Maia.Key.F7;
            s_Keysyms[global::Xcb.KeySym.F8] = Maia.Key.F8;
            s_Keysyms[global::Xcb.KeySym.F9] = Maia.Key.F9;
            s_Keysyms[global::Xcb.KeySym.F10] = Maia.Key.F10;
            s_Keysyms[global::Xcb.KeySym.F11] = Maia.Key.F11;
            s_Keysyms[global::Xcb.KeySym.L1] = Maia.Key.L1;
            s_Keysyms[global::Xcb.KeySym.F12] = Maia.Key.F12;
            s_Keysyms[global::Xcb.KeySym.L2] = Maia.Key.L2;
            s_Keysyms[global::Xcb.KeySym.F13] = Maia.Key.F13;
            s_Keysyms[global::Xcb.KeySym.L3] = Maia.Key.L3;
            s_Keysyms[global::Xcb.KeySym.F14] = Maia.Key.F14;
            s_Keysyms[global::Xcb.KeySym.L4] = Maia.Key.L4;
            s_Keysyms[global::Xcb.KeySym.F15] = Maia.Key.F15;
            s_Keysyms[global::Xcb.KeySym.L5] = Maia.Key.L5;
            s_Keysyms[global::Xcb.KeySym.F16] = Maia.Key.F16;
            s_Keysyms[global::Xcb.KeySym.L6] = Maia.Key.L6;
            s_Keysyms[global::Xcb.KeySym.F17] = Maia.Key.F17;
            s_Keysyms[global::Xcb.KeySym.L7] = Maia.Key.L7;
            s_Keysyms[global::Xcb.KeySym.F18] = Maia.Key.F18;
            s_Keysyms[global::Xcb.KeySym.L8] = Maia.Key.L8;
            s_Keysyms[global::Xcb.KeySym.F19] = Maia.Key.F19;
            s_Keysyms[global::Xcb.KeySym.L9] = Maia.Key.L9;
            s_Keysyms[global::Xcb.KeySym.F20] = Maia.Key.F20;
            s_Keysyms[global::Xcb.KeySym.L10] = Maia.Key.L10;
            s_Keysyms[global::Xcb.KeySym.F21] = Maia.Key.F21;
            s_Keysyms[global::Xcb.KeySym.R1] = Maia.Key.R1;
            s_Keysyms[global::Xcb.KeySym.F22] = Maia.Key.F22;
            s_Keysyms[global::Xcb.KeySym.R2] = Maia.Key.R2;
            s_Keysyms[global::Xcb.KeySym.F23] = Maia.Key.F23;
            s_Keysyms[global::Xcb.KeySym.R3] = Maia.Key.R3;
            s_Keysyms[global::Xcb.KeySym.F24] = Maia.Key.F24;
            s_Keysyms[global::Xcb.KeySym.R4] = Maia.Key.R4;
            s_Keysyms[global::Xcb.KeySym.F25] = Maia.Key.F25;
            s_Keysyms[global::Xcb.KeySym.R5] = Maia.Key.R5;
            s_Keysyms[global::Xcb.KeySym.F26] = Maia.Key.F26;
            s_Keysyms[global::Xcb.KeySym.R6] = Maia.Key.R6;
            s_Keysyms[global::Xcb.KeySym.F27] = Maia.Key.F27;
            s_Keysyms[global::Xcb.KeySym.R7] = Maia.Key.R7;
            s_Keysyms[global::Xcb.KeySym.F28] = Maia.Key.F28;
            s_Keysyms[global::Xcb.KeySym.R8] = Maia.Key.R8;
            s_Keysyms[global::Xcb.KeySym.F29] = Maia.Key.F29;
            s_Keysyms[global::Xcb.KeySym.R9] = Maia.Key.R9;
            s_Keysyms[global::Xcb.KeySym.F30] = Maia.Key.F30;
            s_Keysyms[global::Xcb.KeySym.R10] = Maia.Key.R10;
            s_Keysyms[global::Xcb.KeySym.F31] = Maia.Key.F31;
            s_Keysyms[global::Xcb.KeySym.R11] = Maia.Key.R11;
            s_Keysyms[global::Xcb.KeySym.F32] = Maia.Key.F32;
            s_Keysyms[global::Xcb.KeySym.R12] = Maia.Key.R12;
            s_Keysyms[global::Xcb.KeySym.F33] = Maia.Key.F33;
            s_Keysyms[global::Xcb.KeySym.R13] = Maia.Key.R13;
            s_Keysyms[global::Xcb.KeySym.F34] = Maia.Key.F34;
            s_Keysyms[global::Xcb.KeySym.R14] = Maia.Key.R14;
            s_Keysyms[global::Xcb.KeySym.F35] = Maia.Key.F35;
            s_Keysyms[global::Xcb.KeySym.R15] = Maia.Key.R15;
            s_Keysyms[global::Xcb.KeySym.Shift_L] = Maia.Key.Shift_L;
            s_Keysyms[global::Xcb.KeySym.Shift_R] = Maia.Key.Shift_R;
            s_Keysyms[global::Xcb.KeySym.Control_L] = Maia.Key.Control_L;
            s_Keysyms[global::Xcb.KeySym.Control_R] = Maia.Key.Control_R;
            s_Keysyms[global::Xcb.KeySym.Caps_Lock] = Maia.Key.Caps_Lock;
            s_Keysyms[global::Xcb.KeySym.Shift_Lock] = Maia.Key.Shift_Lock;
            s_Keysyms[global::Xcb.KeySym.Meta_L] = Maia.Key.Meta_L;
            s_Keysyms[global::Xcb.KeySym.Meta_R] = Maia.Key.Meta_R;
            s_Keysyms[global::Xcb.KeySym.Alt_L] = Maia.Key.Alt_L;
            s_Keysyms[global::Xcb.KeySym.Alt_R] = Maia.Key.Alt_R;
            s_Keysyms[global::Xcb.KeySym.Super_L] = Maia.Key.Super_L;
            s_Keysyms[global::Xcb.KeySym.Super_R] = Maia.Key.Super_R;
            s_Keysyms[global::Xcb.KeySym.Hyper_L] = Maia.Key.Hyper_L;
            s_Keysyms[global::Xcb.KeySym.Hyper_R] = Maia.Key.Hyper_R;
            s_Keysyms[global::Xcb.KeySym.ISO_Lock] = Maia.Key.ISO_Lock;
            s_Keysyms[global::Xcb.KeySym.ISO_Level2_Latch] = Maia.Key.ISO_Level2_Latch;
            s_Keysyms[global::Xcb.KeySym.ISO_Level3_Shift] = Maia.Key.ISO_Level3_Shift;
            s_Keysyms[global::Xcb.KeySym.ISO_Level3_Latch] = Maia.Key.ISO_Level3_Latch;
            s_Keysyms[global::Xcb.KeySym.ISO_Level3_Lock] = Maia.Key.ISO_Level3_Lock;
            s_Keysyms[global::Xcb.KeySym.ISO_Level5_Shift] = Maia.Key.ISO_Level5_Shift;
            s_Keysyms[global::Xcb.KeySym.ISO_Level5_Latch] = Maia.Key.ISO_Level5_Latch;
            s_Keysyms[global::Xcb.KeySym.ISO_Level5_Lock] = Maia.Key.ISO_Level5_Lock;
            s_Keysyms[global::Xcb.KeySym.ISO_Group_Shift] = Maia.Key.ISO_Group_Shift;
            s_Keysyms[global::Xcb.KeySym.ISO_Group_Latch] = Maia.Key.ISO_Group_Latch;
            s_Keysyms[global::Xcb.KeySym.ISO_Group_Lock] = Maia.Key.ISO_Group_Lock;
            s_Keysyms[global::Xcb.KeySym.ISO_Next_Group] = Maia.Key.ISO_Next_Group;
            s_Keysyms[global::Xcb.KeySym.ISO_Next_Group_Lock] = Maia.Key.ISO_Next_Group_Lock;
            s_Keysyms[global::Xcb.KeySym.ISO_Prev_Group] = Maia.Key.ISO_Prev_Group;
            s_Keysyms[global::Xcb.KeySym.ISO_Prev_Group_Lock] = Maia.Key.ISO_Prev_Group_Lock;
            s_Keysyms[global::Xcb.KeySym.ISO_First_Group] = Maia.Key.ISO_First_Group;
            s_Keysyms[global::Xcb.KeySym.ISO_First_Group_Lock] = Maia.Key.ISO_First_Group_Lock;
            s_Keysyms[global::Xcb.KeySym.ISO_Last_Group] = Maia.Key.ISO_Last_Group;
            s_Keysyms[global::Xcb.KeySym.ISO_Last_Group_Lock] = Maia.Key.ISO_Last_Group_Lock;
            s_Keysyms[global::Xcb.KeySym.ISO_Left_Tab] = Maia.Key.ISO_Left_Tab;
            s_Keysyms[global::Xcb.KeySym.ISO_Move_Line_Up] = Maia.Key.ISO_Move_Line_Up;
            s_Keysyms[global::Xcb.KeySym.ISO_Move_Line_Down] = Maia.Key.ISO_Move_Line_Down;
            s_Keysyms[global::Xcb.KeySym.ISO_Partial_Line_Up] = Maia.Key.ISO_Partial_Line_Up;
            s_Keysyms[global::Xcb.KeySym.ISO_Partial_Line_Down] = Maia.Key.ISO_Partial_Line_Down;
            s_Keysyms[global::Xcb.KeySym.ISO_Partial_Space_Left] = Maia.Key.ISO_Partial_Space_Left;
            s_Keysyms[global::Xcb.KeySym.ISO_Partial_Space_Right] = Maia.Key.ISO_Partial_Space_Right;
            s_Keysyms[global::Xcb.KeySym.ISO_Set_Margin_Left] = Maia.Key.ISO_Set_Margin_Left;
            s_Keysyms[global::Xcb.KeySym.ISO_Set_Margin_Right] = Maia.Key.ISO_Set_Margin_Right;
            s_Keysyms[global::Xcb.KeySym.ISO_Release_Margin_Left] = Maia.Key.ISO_Release_Margin_Left;
            s_Keysyms[global::Xcb.KeySym.ISO_Release_Margin_Right] = Maia.Key.ISO_Release_Margin_Right;
            s_Keysyms[global::Xcb.KeySym.ISO_Release_Both_Margins] = Maia.Key.ISO_Release_Both_Margins;
            s_Keysyms[global::Xcb.KeySym.ISO_Fast_Cursor_Left] = Maia.Key.ISO_Fast_Cursor_Left;
            s_Keysyms[global::Xcb.KeySym.ISO_Fast_Cursor_Right] = Maia.Key.ISO_Fast_Cursor_Right;
            s_Keysyms[global::Xcb.KeySym.ISO_Fast_Cursor_Up] = Maia.Key.ISO_Fast_Cursor_Up;
            s_Keysyms[global::Xcb.KeySym.ISO_Fast_Cursor_Down] = Maia.Key.ISO_Fast_Cursor_Down;
            s_Keysyms[global::Xcb.KeySym.ISO_Continuous_Underline] = Maia.Key.ISO_Continuous_Underline;
            s_Keysyms[global::Xcb.KeySym.ISO_Discontinuous_Underline] = Maia.Key.ISO_Discontinuous_Underline;
            s_Keysyms[global::Xcb.KeySym.ISO_Emphasize] = Maia.Key.ISO_Emphasize;
            s_Keysyms[global::Xcb.KeySym.ISO_Center_Object] = Maia.Key.ISO_Center_Object;
            s_Keysyms[global::Xcb.KeySym.ISO_Enter] = Maia.Key.ISO_Enter;
            s_Keysyms[global::Xcb.KeySym.dead_grave] = Maia.Key.dead_grave;
            s_Keysyms[global::Xcb.KeySym.dead_acute] = Maia.Key.dead_acute;
            s_Keysyms[global::Xcb.KeySym.dead_circumflex] = Maia.Key.dead_circumflex;
            s_Keysyms[global::Xcb.KeySym.dead_tilde] = Maia.Key.dead_tilde;
            s_Keysyms[global::Xcb.KeySym.dead_perispomeni] = Maia.Key.dead_perispomeni;
            s_Keysyms[global::Xcb.KeySym.dead_macron] = Maia.Key.dead_macron;
            s_Keysyms[global::Xcb.KeySym.dead_breve] = Maia.Key.dead_breve;
            s_Keysyms[global::Xcb.KeySym.dead_abovedot] = Maia.Key.dead_abovedot;
            s_Keysyms[global::Xcb.KeySym.dead_diaeresis] = Maia.Key.dead_diaeresis;
            s_Keysyms[global::Xcb.KeySym.dead_abovering] = Maia.Key.dead_abovering;
            s_Keysyms[global::Xcb.KeySym.dead_doubleacute] = Maia.Key.dead_doubleacute;
            s_Keysyms[global::Xcb.KeySym.dead_caron] = Maia.Key.dead_caron;
            s_Keysyms[global::Xcb.KeySym.dead_cedilla] = Maia.Key.dead_cedilla;
            s_Keysyms[global::Xcb.KeySym.dead_ogonek] = Maia.Key.dead_ogonek;
            s_Keysyms[global::Xcb.KeySym.dead_iota] = Maia.Key.dead_iota;
            s_Keysyms[global::Xcb.KeySym.dead_voiced_sound] = Maia.Key.dead_voiced_sound;
            s_Keysyms[global::Xcb.KeySym.dead_semivoiced_sound] = Maia.Key.dead_semivoiced_sound;
            s_Keysyms[global::Xcb.KeySym.dead_belowdot] = Maia.Key.dead_belowdot;
            s_Keysyms[global::Xcb.KeySym.dead_hook] = Maia.Key.dead_hook;
            s_Keysyms[global::Xcb.KeySym.dead_horn] = Maia.Key.dead_horn;
            s_Keysyms[global::Xcb.KeySym.dead_stroke] = Maia.Key.dead_stroke;
            s_Keysyms[global::Xcb.KeySym.dead_abovecomma] = Maia.Key.dead_abovecomma;
            s_Keysyms[global::Xcb.KeySym.dead_psili] = Maia.Key.dead_psili;
            s_Keysyms[global::Xcb.KeySym.dead_abovereversedcomma] = Maia.Key.dead_abovereversedcomma;
            s_Keysyms[global::Xcb.KeySym.dead_dasia] = Maia.Key.dead_dasia;
            s_Keysyms[global::Xcb.KeySym.dead_doublegrave] = Maia.Key.dead_doublegrave;
            s_Keysyms[global::Xcb.KeySym.dead_belowring] = Maia.Key.dead_belowring;
            s_Keysyms[global::Xcb.KeySym.dead_belowmacron] = Maia.Key.dead_belowmacron;
            s_Keysyms[global::Xcb.KeySym.dead_belowcircumflex] = Maia.Key.dead_belowcircumflex;
            s_Keysyms[global::Xcb.KeySym.dead_belowtilde] = Maia.Key.dead_belowtilde;
            s_Keysyms[global::Xcb.KeySym.dead_belowbreve] = Maia.Key.dead_belowbreve;
            s_Keysyms[global::Xcb.KeySym.dead_belowdiaeresis] = Maia.Key.dead_belowdiaeresis;
            s_Keysyms[global::Xcb.KeySym.dead_invertedbreve] = Maia.Key.dead_invertedbreve;
            s_Keysyms[global::Xcb.KeySym.dead_belowcomma] = Maia.Key.dead_belowcomma;
            s_Keysyms[global::Xcb.KeySym.dead_currency] = Maia.Key.dead_currency;
            s_Keysyms[global::Xcb.KeySym.dead_a] = Maia.Key.dead_a;
            s_Keysyms[global::Xcb.KeySym.dead_A] = Maia.Key.dead_A;
            s_Keysyms[global::Xcb.KeySym.dead_e] = Maia.Key.dead_e;
            s_Keysyms[global::Xcb.KeySym.dead_E] = Maia.Key.dead_E;
            s_Keysyms[global::Xcb.KeySym.dead_i] = Maia.Key.dead_i;
            s_Keysyms[global::Xcb.KeySym.dead_I] = Maia.Key.dead_I;
            s_Keysyms[global::Xcb.KeySym.dead_o] = Maia.Key.dead_o;
            s_Keysyms[global::Xcb.KeySym.dead_O] = Maia.Key.dead_O;
            s_Keysyms[global::Xcb.KeySym.dead_u] = Maia.Key.dead_u;
            s_Keysyms[global::Xcb.KeySym.dead_U] = Maia.Key.dead_U;
            s_Keysyms[global::Xcb.KeySym.dead_small_schwa] = Maia.Key.dead_small_schwa;
            s_Keysyms[global::Xcb.KeySym.dead_capital_schwa] = Maia.Key.dead_capital_schwa;
            s_Keysyms[global::Xcb.KeySym.First_Virtual_Screen] = Maia.Key.First_Virtual_Screen;
            s_Keysyms[global::Xcb.KeySym.Prev_Virtual_Screen] = Maia.Key.Prev_Virtual_Screen;
            s_Keysyms[global::Xcb.KeySym.Next_Virtual_Screen] = Maia.Key.Next_Virtual_Screen;
            s_Keysyms[global::Xcb.KeySym.Last_Virtual_Screen] = Maia.Key.Last_Virtual_Screen;
            s_Keysyms[global::Xcb.KeySym.Terminate_Server] = Maia.Key.Terminate_Server;
            s_Keysyms[global::Xcb.KeySym.AccessX_Enable] = Maia.Key.AccessX_Enable;
            s_Keysyms[global::Xcb.KeySym.AccessX_Feedback_Enable] = Maia.Key.AccessX_Feedback_Enable;
            s_Keysyms[global::Xcb.KeySym.RepeatKeys_Enable] = Maia.Key.RepeatKeys_Enable;
            s_Keysyms[global::Xcb.KeySym.SlowKeys_Enable] = Maia.Key.SlowKeys_Enable;
            s_Keysyms[global::Xcb.KeySym.BounceKeys_Enable] = Maia.Key.BounceKeys_Enable;
            s_Keysyms[global::Xcb.KeySym.StickyKeys_Enable] = Maia.Key.StickyKeys_Enable;
            s_Keysyms[global::Xcb.KeySym.MouseKeys_Enable] = Maia.Key.MouseKeys_Enable;
            s_Keysyms[global::Xcb.KeySym.MouseKeys_Accel_Enable] = Maia.Key.MouseKeys_Accel_Enable;
            s_Keysyms[global::Xcb.KeySym.Overlay1_Enable] = Maia.Key.Overlay1_Enable;
            s_Keysyms[global::Xcb.KeySym.Overlay2_Enable] = Maia.Key.Overlay2_Enable;
            s_Keysyms[global::Xcb.KeySym.AudibleBell_Enable] = Maia.Key.AudibleBell_Enable;
            s_Keysyms[global::Xcb.KeySym.Pointer_Left] = Maia.Key.Pointer_Left;
            s_Keysyms[global::Xcb.KeySym.Pointer_Right] = Maia.Key.Pointer_Right;
            s_Keysyms[global::Xcb.KeySym.Pointer_Up] = Maia.Key.Pointer_Up;
            s_Keysyms[global::Xcb.KeySym.Pointer_Down] = Maia.Key.Pointer_Down;
            s_Keysyms[global::Xcb.KeySym.Pointer_UpLeft] = Maia.Key.Pointer_UpLeft;
            s_Keysyms[global::Xcb.KeySym.Pointer_UpRight] = Maia.Key.Pointer_UpRight;
            s_Keysyms[global::Xcb.KeySym.Pointer_DownLeft] = Maia.Key.Pointer_DownLeft;
            s_Keysyms[global::Xcb.KeySym.Pointer_DownRight] = Maia.Key.Pointer_DownRight;
            s_Keysyms[global::Xcb.KeySym.Pointer_Button_Dflt] = Maia.Key.Pointer_Button_Dflt;
            s_Keysyms[global::Xcb.KeySym.Pointer_Button1] = Maia.Key.Pointer_Button1;
            s_Keysyms[global::Xcb.KeySym.Pointer_Button2] = Maia.Key.Pointer_Button2;
            s_Keysyms[global::Xcb.KeySym.Pointer_Button3] = Maia.Key.Pointer_Button3;
            s_Keysyms[global::Xcb.KeySym.Pointer_Button4] = Maia.Key.Pointer_Button4;
            s_Keysyms[global::Xcb.KeySym.Pointer_Button5] = Maia.Key.Pointer_Button5;
            s_Keysyms[global::Xcb.KeySym.Pointer_DblClick_Dflt] = Maia.Key.Pointer_DblClick_Dflt;
            s_Keysyms[global::Xcb.KeySym.Pointer_DblClick1] = Maia.Key.Pointer_DblClick1;
            s_Keysyms[global::Xcb.KeySym.Pointer_DblClick2] = Maia.Key.Pointer_DblClick2;
            s_Keysyms[global::Xcb.KeySym.Pointer_DblClick3] = Maia.Key.Pointer_DblClick3;
            s_Keysyms[global::Xcb.KeySym.Pointer_DblClick4] = Maia.Key.Pointer_DblClick4;
            s_Keysyms[global::Xcb.KeySym.Pointer_DblClick5] = Maia.Key.Pointer_DblClick5;
            s_Keysyms[global::Xcb.KeySym.Pointer_Drag_Dflt] = Maia.Key.Pointer_Drag_Dflt;
            s_Keysyms[global::Xcb.KeySym.Pointer_Drag1] = Maia.Key.Pointer_Drag1;
            s_Keysyms[global::Xcb.KeySym.Pointer_Drag2] = Maia.Key.Pointer_Drag2;
            s_Keysyms[global::Xcb.KeySym.Pointer_Drag3] = Maia.Key.Pointer_Drag3;
            s_Keysyms[global::Xcb.KeySym.Pointer_Drag4] = Maia.Key.Pointer_Drag4;
            s_Keysyms[global::Xcb.KeySym.Pointer_Drag5] = Maia.Key.Pointer_Drag5;
            s_Keysyms[global::Xcb.KeySym.Pointer_EnableKeys] = Maia.Key.Pointer_EnableKeys;
            s_Keysyms[global::Xcb.KeySym.Pointer_Accelerate] = Maia.Key.Pointer_Accelerate;
            s_Keysyms[global::Xcb.KeySym.Pointer_DfltBtnNext] = Maia.Key.Pointer_DfltBtnNext;
            s_Keysyms[global::Xcb.KeySym.Pointer_DfltBtnPrev] = Maia.Key.Pointer_DfltBtnPrev;
            s_Keysyms[global::Xcb.KeySym.space] = Maia.Key.space;
            s_Keysyms[global::Xcb.KeySym.exclam] = Maia.Key.exclam;
            s_Keysyms[global::Xcb.KeySym.quotedbl] = Maia.Key.quotedbl;
            s_Keysyms[global::Xcb.KeySym.numbersign] = Maia.Key.numbersign;
            s_Keysyms[global::Xcb.KeySym.dollar] = Maia.Key.dollar;
            s_Keysyms[global::Xcb.KeySym.percent] = Maia.Key.percent;
            s_Keysyms[global::Xcb.KeySym.ampersand] = Maia.Key.ampersand;
            s_Keysyms[global::Xcb.KeySym.apostrophe] = Maia.Key.apostrophe;
            s_Keysyms[global::Xcb.KeySym.quoteright] = Maia.Key.quoteright;
            s_Keysyms[global::Xcb.KeySym.parenleft] = Maia.Key.parenleft;
            s_Keysyms[global::Xcb.KeySym.parenright] = Maia.Key.parenright;
            s_Keysyms[global::Xcb.KeySym.asterisk] = Maia.Key.asterisk;
            s_Keysyms[global::Xcb.KeySym.plus] = Maia.Key.plus;
            s_Keysyms[global::Xcb.KeySym.comma] = Maia.Key.comma;
            s_Keysyms[global::Xcb.KeySym.minus] = Maia.Key.minus;
            s_Keysyms[global::Xcb.KeySym.period] = Maia.Key.period;
            s_Keysyms[global::Xcb.KeySym.slash] = Maia.Key.slash;
            s_Keysyms[global::Xcb.KeySym.@0] = Maia.Key.@0;
            s_Keysyms[global::Xcb.KeySym.@1] = Maia.Key.@1;
            s_Keysyms[global::Xcb.KeySym.@2] = Maia.Key.@2;
            s_Keysyms[global::Xcb.KeySym.@3] = Maia.Key.@3;
            s_Keysyms[global::Xcb.KeySym.@4] = Maia.Key.@4;
            s_Keysyms[global::Xcb.KeySym.@5] = Maia.Key.@5;
            s_Keysyms[global::Xcb.KeySym.@6] = Maia.Key.@6;
            s_Keysyms[global::Xcb.KeySym.@7] = Maia.Key.@7;
            s_Keysyms[global::Xcb.KeySym.@8] = Maia.Key.@8;
            s_Keysyms[global::Xcb.KeySym.@9] = Maia.Key.@9;
            s_Keysyms[global::Xcb.KeySym.colon] = Maia.Key.colon;
            s_Keysyms[global::Xcb.KeySym.semicolon] = Maia.Key.semicolon;
            s_Keysyms[global::Xcb.KeySym.less] = Maia.Key.less;
            s_Keysyms[global::Xcb.KeySym.equal] = Maia.Key.equal;
            s_Keysyms[global::Xcb.KeySym.greater] = Maia.Key.greater;
            s_Keysyms[global::Xcb.KeySym.question] = Maia.Key.question;
            s_Keysyms[global::Xcb.KeySym.at] = Maia.Key.at;
            s_Keysyms[global::Xcb.KeySym.A] = Maia.Key.A;
            s_Keysyms[global::Xcb.KeySym.B] = Maia.Key.B;
            s_Keysyms[global::Xcb.KeySym.C] = Maia.Key.C;
            s_Keysyms[global::Xcb.KeySym.D] = Maia.Key.D;
            s_Keysyms[global::Xcb.KeySym.E] = Maia.Key.E;
            s_Keysyms[global::Xcb.KeySym.F] = Maia.Key.F;
            s_Keysyms[global::Xcb.KeySym.G] = Maia.Key.G;
            s_Keysyms[global::Xcb.KeySym.H] = Maia.Key.H;
            s_Keysyms[global::Xcb.KeySym.I] = Maia.Key.I;
            s_Keysyms[global::Xcb.KeySym.J] = Maia.Key.J;
            s_Keysyms[global::Xcb.KeySym.K] = Maia.Key.K;
            s_Keysyms[global::Xcb.KeySym.L] = Maia.Key.L;
            s_Keysyms[global::Xcb.KeySym.M] = Maia.Key.M;
            s_Keysyms[global::Xcb.KeySym.N] = Maia.Key.N;
            s_Keysyms[global::Xcb.KeySym.O] = Maia.Key.O;
            s_Keysyms[global::Xcb.KeySym.P] = Maia.Key.P;
            s_Keysyms[global::Xcb.KeySym.Q] = Maia.Key.Q;
            s_Keysyms[global::Xcb.KeySym.R] = Maia.Key.R;
            s_Keysyms[global::Xcb.KeySym.S] = Maia.Key.S;
            s_Keysyms[global::Xcb.KeySym.T] = Maia.Key.T;
            s_Keysyms[global::Xcb.KeySym.U] = Maia.Key.U;
            s_Keysyms[global::Xcb.KeySym.V] = Maia.Key.V;
            s_Keysyms[global::Xcb.KeySym.W] = Maia.Key.W;
            s_Keysyms[global::Xcb.KeySym.X] = Maia.Key.X;
            s_Keysyms[global::Xcb.KeySym.Y] = Maia.Key.Y;
            s_Keysyms[global::Xcb.KeySym.Z] = Maia.Key.Z;
            s_Keysyms[global::Xcb.KeySym.bracketleft] = Maia.Key.bracketleft;
            s_Keysyms[global::Xcb.KeySym.backslash] = Maia.Key.backslash;
            s_Keysyms[global::Xcb.KeySym.bracketright] = Maia.Key.bracketright;
            s_Keysyms[global::Xcb.KeySym.asciicircum] = Maia.Key.asciicircum;
            s_Keysyms[global::Xcb.KeySym.underscore] = Maia.Key.underscore;
            s_Keysyms[global::Xcb.KeySym.grave] = Maia.Key.grave;
            s_Keysyms[global::Xcb.KeySym.quoteleft] = Maia.Key.quoteleft;
            s_Keysyms[global::Xcb.KeySym.a] = Maia.Key.a;
            s_Keysyms[global::Xcb.KeySym.b] = Maia.Key.b;
            s_Keysyms[global::Xcb.KeySym.c] = Maia.Key.c;
            s_Keysyms[global::Xcb.KeySym.d] = Maia.Key.d;
            s_Keysyms[global::Xcb.KeySym.e] = Maia.Key.e;
            s_Keysyms[global::Xcb.KeySym.f] = Maia.Key.f;
            s_Keysyms[global::Xcb.KeySym.g] = Maia.Key.g;
            s_Keysyms[global::Xcb.KeySym.h] = Maia.Key.h;
            s_Keysyms[global::Xcb.KeySym.i] = Maia.Key.i;
            s_Keysyms[global::Xcb.KeySym.j] = Maia.Key.j;
            s_Keysyms[global::Xcb.KeySym.k] = Maia.Key.k;
            s_Keysyms[global::Xcb.KeySym.l] = Maia.Key.l;
            s_Keysyms[global::Xcb.KeySym.m] = Maia.Key.m;
            s_Keysyms[global::Xcb.KeySym.n] = Maia.Key.n;
            s_Keysyms[global::Xcb.KeySym.o] = Maia.Key.o;
            s_Keysyms[global::Xcb.KeySym.p] = Maia.Key.p;
            s_Keysyms[global::Xcb.KeySym.q] = Maia.Key.q;
            s_Keysyms[global::Xcb.KeySym.r] = Maia.Key.r;
            s_Keysyms[global::Xcb.KeySym.s] = Maia.Key.s;
            s_Keysyms[global::Xcb.KeySym.t] = Maia.Key.t;
            s_Keysyms[global::Xcb.KeySym.u] = Maia.Key.u;
            s_Keysyms[global::Xcb.KeySym.v] = Maia.Key.v;
            s_Keysyms[global::Xcb.KeySym.w] = Maia.Key.w;
            s_Keysyms[global::Xcb.KeySym.x] = Maia.Key.x;
            s_Keysyms[global::Xcb.KeySym.y] = Maia.Key.y;
            s_Keysyms[global::Xcb.KeySym.z] = Maia.Key.z;
            s_Keysyms[global::Xcb.KeySym.braceleft] = Maia.Key.braceleft;
            s_Keysyms[global::Xcb.KeySym.bar] = Maia.Key.bar;
            s_Keysyms[global::Xcb.KeySym.braceright] = Maia.Key.braceright;
            s_Keysyms[global::Xcb.KeySym.asciitilde] = Maia.Key.asciitilde;
            s_Keysyms[global::Xcb.KeySym.nobreakspace] = Maia.Key.nobreakspace;
            s_Keysyms[global::Xcb.KeySym.exclamdown] = Maia.Key.exclamdown;
            s_Keysyms[global::Xcb.KeySym.cent] = Maia.Key.cent;
            s_Keysyms[global::Xcb.KeySym.sterling] = Maia.Key.sterling;
            s_Keysyms[global::Xcb.KeySym.currency] = Maia.Key.currency;
            s_Keysyms[global::Xcb.KeySym.yen] = Maia.Key.yen;
            s_Keysyms[global::Xcb.KeySym.brokenbar] = Maia.Key.brokenbar;
            s_Keysyms[global::Xcb.KeySym.section] = Maia.Key.section;
            s_Keysyms[global::Xcb.KeySym.diaeresis] = Maia.Key.diaeresis;
            s_Keysyms[global::Xcb.KeySym.copyright] = Maia.Key.copyright;
            s_Keysyms[global::Xcb.KeySym.ordfeminine] = Maia.Key.ordfeminine;
            s_Keysyms[global::Xcb.KeySym.guillemotleft] = Maia.Key.guillemotleft;
            s_Keysyms[global::Xcb.KeySym.notsign] = Maia.Key.notsign;
            s_Keysyms[global::Xcb.KeySym.hyphen] = Maia.Key.hyphen;
            s_Keysyms[global::Xcb.KeySym.registered] = Maia.Key.registered;
            s_Keysyms[global::Xcb.KeySym.macron] = Maia.Key.macron;
            s_Keysyms[global::Xcb.KeySym.degree] = Maia.Key.degree;
            s_Keysyms[global::Xcb.KeySym.plusminus] = Maia.Key.plusminus;
            s_Keysyms[global::Xcb.KeySym.twosuperior] = Maia.Key.twosuperior;
            s_Keysyms[global::Xcb.KeySym.threesuperior] = Maia.Key.threesuperior;
            s_Keysyms[global::Xcb.KeySym.acute] = Maia.Key.acute;
            s_Keysyms[global::Xcb.KeySym.mu] = Maia.Key.mu;
            s_Keysyms[global::Xcb.KeySym.paragraph] = Maia.Key.paragraph;
            s_Keysyms[global::Xcb.KeySym.periodcentered] = Maia.Key.periodcentered;
            s_Keysyms[global::Xcb.KeySym.cedilla] = Maia.Key.cedilla;
            s_Keysyms[global::Xcb.KeySym.onesuperior] = Maia.Key.onesuperior;
            s_Keysyms[global::Xcb.KeySym.masculine] = Maia.Key.masculine;
            s_Keysyms[global::Xcb.KeySym.guillemotright] = Maia.Key.guillemotright;
            s_Keysyms[global::Xcb.KeySym.onequarter] = Maia.Key.onequarter;
            s_Keysyms[global::Xcb.KeySym.onehalf] = Maia.Key.onehalf;
            s_Keysyms[global::Xcb.KeySym.threequarters] = Maia.Key.threequarters;
            s_Keysyms[global::Xcb.KeySym.questiondown] = Maia.Key.questiondown;
            s_Keysyms[global::Xcb.KeySym.Agrave] = Maia.Key.Agrave;
            s_Keysyms[global::Xcb.KeySym.Aacute] = Maia.Key.Aacute;
            s_Keysyms[global::Xcb.KeySym.Acircumflex] = Maia.Key.Acircumflex;
            s_Keysyms[global::Xcb.KeySym.Atilde] = Maia.Key.Atilde;
            s_Keysyms[global::Xcb.KeySym.Adiaeresis] = Maia.Key.Adiaeresis;
            s_Keysyms[global::Xcb.KeySym.Aring] = Maia.Key.Aring;
            s_Keysyms[global::Xcb.KeySym.AE] = Maia.Key.AE;
            s_Keysyms[global::Xcb.KeySym.Ccedilla] = Maia.Key.Ccedilla;
            s_Keysyms[global::Xcb.KeySym.Egrave] = Maia.Key.Egrave;
            s_Keysyms[global::Xcb.KeySym.Eacute] = Maia.Key.Eacute;
            s_Keysyms[global::Xcb.KeySym.Ecircumflex] = Maia.Key.Ecircumflex;
            s_Keysyms[global::Xcb.KeySym.Ediaeresis] = Maia.Key.Ediaeresis;
            s_Keysyms[global::Xcb.KeySym.Igrave] = Maia.Key.Igrave;
            s_Keysyms[global::Xcb.KeySym.Iacute] = Maia.Key.Iacute;
            s_Keysyms[global::Xcb.KeySym.Icircumflex] = Maia.Key.Icircumflex;
            s_Keysyms[global::Xcb.KeySym.Idiaeresis] = Maia.Key.Idiaeresis;
            s_Keysyms[global::Xcb.KeySym.ETH] = Maia.Key.ETH;
            s_Keysyms[global::Xcb.KeySym.Eth] = Maia.Key.Eth;
            s_Keysyms[global::Xcb.KeySym.Ntilde] = Maia.Key.Ntilde;
            s_Keysyms[global::Xcb.KeySym.Ograve] = Maia.Key.Ograve;
            s_Keysyms[global::Xcb.KeySym.Oacute] = Maia.Key.Oacute;
            s_Keysyms[global::Xcb.KeySym.Ocircumflex] = Maia.Key.Ocircumflex;
            s_Keysyms[global::Xcb.KeySym.Otilde] = Maia.Key.Otilde;
            s_Keysyms[global::Xcb.KeySym.Odiaeresis] = Maia.Key.Odiaeresis;
            s_Keysyms[global::Xcb.KeySym.multiply] = Maia.Key.multiply;
            s_Keysyms[global::Xcb.KeySym.Oslash] = Maia.Key.Oslash;
            s_Keysyms[global::Xcb.KeySym.Ooblique] = Maia.Key.Ooblique;
            s_Keysyms[global::Xcb.KeySym.Ugrave] = Maia.Key.Ugrave;
            s_Keysyms[global::Xcb.KeySym.Uacute] = Maia.Key.Uacute;
            s_Keysyms[global::Xcb.KeySym.Ucircumflex] = Maia.Key.Ucircumflex;
            s_Keysyms[global::Xcb.KeySym.Udiaeresis] = Maia.Key.Udiaeresis;
            s_Keysyms[global::Xcb.KeySym.Yacute] = Maia.Key.Yacute;
            s_Keysyms[global::Xcb.KeySym.THORN] = Maia.Key.THORN;
            s_Keysyms[global::Xcb.KeySym.Thorn] = Maia.Key.Thorn;
            s_Keysyms[global::Xcb.KeySym.ssharp] = Maia.Key.ssharp;
            s_Keysyms[global::Xcb.KeySym.agrave] = Maia.Key.agrave;
            s_Keysyms[global::Xcb.KeySym.aacute] = Maia.Key.aacute;
            s_Keysyms[global::Xcb.KeySym.acircumflex] = Maia.Key.acircumflex;
            s_Keysyms[global::Xcb.KeySym.atilde] = Maia.Key.atilde;
            s_Keysyms[global::Xcb.KeySym.adiaeresis] = Maia.Key.adiaeresis;
            s_Keysyms[global::Xcb.KeySym.aring] = Maia.Key.aring;
            s_Keysyms[global::Xcb.KeySym.ae] = Maia.Key.ae;
            s_Keysyms[global::Xcb.KeySym.ccedilla] = Maia.Key.ccedilla;
            s_Keysyms[global::Xcb.KeySym.egrave] = Maia.Key.egrave;
            s_Keysyms[global::Xcb.KeySym.eacute] = Maia.Key.eacute;
            s_Keysyms[global::Xcb.KeySym.ecircumflex] = Maia.Key.ecircumflex;
            s_Keysyms[global::Xcb.KeySym.ediaeresis] = Maia.Key.ediaeresis;
            s_Keysyms[global::Xcb.KeySym.igrave] = Maia.Key.igrave;
            s_Keysyms[global::Xcb.KeySym.iacute] = Maia.Key.iacute;
            s_Keysyms[global::Xcb.KeySym.icircumflex] = Maia.Key.icircumflex;
            s_Keysyms[global::Xcb.KeySym.idiaeresis] = Maia.Key.idiaeresis;
            s_Keysyms[global::Xcb.KeySym.eth] = Maia.Key.eth;
            s_Keysyms[global::Xcb.KeySym.ntilde] = Maia.Key.ntilde;
            s_Keysyms[global::Xcb.KeySym.ograve] = Maia.Key.ograve;
            s_Keysyms[global::Xcb.KeySym.oacute] = Maia.Key.oacute;
            s_Keysyms[global::Xcb.KeySym.ocircumflex] = Maia.Key.ocircumflex;
            s_Keysyms[global::Xcb.KeySym.otilde] = Maia.Key.otilde;
            s_Keysyms[global::Xcb.KeySym.odiaeresis] = Maia.Key.odiaeresis;
            s_Keysyms[global::Xcb.KeySym.division] = Maia.Key.division;
            s_Keysyms[global::Xcb.KeySym.oslash] = Maia.Key.oslash;
            s_Keysyms[global::Xcb.KeySym.ooblique] = Maia.Key.ooblique;
            s_Keysyms[global::Xcb.KeySym.ugrave] = Maia.Key.ugrave;
            s_Keysyms[global::Xcb.KeySym.uacute] = Maia.Key.uacute;
            s_Keysyms[global::Xcb.KeySym.ucircumflex] = Maia.Key.ucircumflex;
            s_Keysyms[global::Xcb.KeySym.udiaeresis] = Maia.Key.udiaeresis;
            s_Keysyms[global::Xcb.KeySym.yacute] = Maia.Key.yacute;
            s_Keysyms[global::Xcb.KeySym.thorn] = Maia.Key.thorn;
            s_Keysyms[global::Xcb.KeySym.ydiaeresis] = Maia.Key.ydiaeresis;
            s_Keysyms[global::Xcb.KeySym.Aogonek] = Maia.Key.Aogonek;
            s_Keysyms[global::Xcb.KeySym.breve] = Maia.Key.breve;
            s_Keysyms[global::Xcb.KeySym.Lstroke] = Maia.Key.Lstroke;
            s_Keysyms[global::Xcb.KeySym.Lcaron] = Maia.Key.Lcaron;
            s_Keysyms[global::Xcb.KeySym.Sacute] = Maia.Key.Sacute;
            s_Keysyms[global::Xcb.KeySym.Scaron] = Maia.Key.Scaron;
            s_Keysyms[global::Xcb.KeySym.Scedilla] = Maia.Key.Scedilla;
            s_Keysyms[global::Xcb.KeySym.Tcaron] = Maia.Key.Tcaron;
            s_Keysyms[global::Xcb.KeySym.Zacute] = Maia.Key.Zacute;
            s_Keysyms[global::Xcb.KeySym.Zcaron] = Maia.Key.Zcaron;
            s_Keysyms[global::Xcb.KeySym.Zabovedot] = Maia.Key.Zabovedot;
            s_Keysyms[global::Xcb.KeySym.aogonek] = Maia.Key.aogonek;
            s_Keysyms[global::Xcb.KeySym.ogonek] = Maia.Key.ogonek;
            s_Keysyms[global::Xcb.KeySym.lstroke] = Maia.Key.lstroke;
            s_Keysyms[global::Xcb.KeySym.lcaron] = Maia.Key.lcaron;
            s_Keysyms[global::Xcb.KeySym.sacute] = Maia.Key.sacute;
            s_Keysyms[global::Xcb.KeySym.caron] = Maia.Key.caron;
            s_Keysyms[global::Xcb.KeySym.scaron] = Maia.Key.scaron;
            s_Keysyms[global::Xcb.KeySym.scedilla] = Maia.Key.scedilla;
            s_Keysyms[global::Xcb.KeySym.tcaron] = Maia.Key.tcaron;
            s_Keysyms[global::Xcb.KeySym.zacute] = Maia.Key.zacute;
            s_Keysyms[global::Xcb.KeySym.doubleacute] = Maia.Key.doubleacute;
            s_Keysyms[global::Xcb.KeySym.zcaron] = Maia.Key.zcaron;
            s_Keysyms[global::Xcb.KeySym.zabovedot] = Maia.Key.zabovedot;
            s_Keysyms[global::Xcb.KeySym.Racute] = Maia.Key.Racute;
            s_Keysyms[global::Xcb.KeySym.Abreve] = Maia.Key.Abreve;
            s_Keysyms[global::Xcb.KeySym.Lacute] = Maia.Key.Lacute;
            s_Keysyms[global::Xcb.KeySym.Cacute] = Maia.Key.Cacute;
            s_Keysyms[global::Xcb.KeySym.Ccaron] = Maia.Key.Ccaron;
            s_Keysyms[global::Xcb.KeySym.Eogonek] = Maia.Key.Eogonek;
            s_Keysyms[global::Xcb.KeySym.Ecaron] = Maia.Key.Ecaron;
            s_Keysyms[global::Xcb.KeySym.Dcaron] = Maia.Key.Dcaron;
            s_Keysyms[global::Xcb.KeySym.Dstroke] = Maia.Key.Dstroke;
            s_Keysyms[global::Xcb.KeySym.Nacute] = Maia.Key.Nacute;
            s_Keysyms[global::Xcb.KeySym.Ncaron] = Maia.Key.Ncaron;
            s_Keysyms[global::Xcb.KeySym.Odoubleacute] = Maia.Key.Odoubleacute;
            s_Keysyms[global::Xcb.KeySym.Rcaron] = Maia.Key.Rcaron;
            s_Keysyms[global::Xcb.KeySym.Uring] = Maia.Key.Uring;
            s_Keysyms[global::Xcb.KeySym.Udoubleacute] = Maia.Key.Udoubleacute;
            s_Keysyms[global::Xcb.KeySym.Tcedilla] = Maia.Key.Tcedilla;
            s_Keysyms[global::Xcb.KeySym.racute] = Maia.Key.racute;
            s_Keysyms[global::Xcb.KeySym.abreve] = Maia.Key.abreve;
            s_Keysyms[global::Xcb.KeySym.lacute] = Maia.Key.lacute;
            s_Keysyms[global::Xcb.KeySym.cacute] = Maia.Key.cacute;
            s_Keysyms[global::Xcb.KeySym.ccaron] = Maia.Key.ccaron;
            s_Keysyms[global::Xcb.KeySym.eogonek] = Maia.Key.eogonek;
            s_Keysyms[global::Xcb.KeySym.ecaron] = Maia.Key.ecaron;
            s_Keysyms[global::Xcb.KeySym.dcaron] = Maia.Key.dcaron;
            s_Keysyms[global::Xcb.KeySym.dstroke] = Maia.Key.dstroke;
            s_Keysyms[global::Xcb.KeySym.nacute] = Maia.Key.nacute;
            s_Keysyms[global::Xcb.KeySym.ncaron] = Maia.Key.ncaron;
            s_Keysyms[global::Xcb.KeySym.odoubleacute] = Maia.Key.odoubleacute;
            s_Keysyms[global::Xcb.KeySym.rcaron] = Maia.Key.rcaron;
            s_Keysyms[global::Xcb.KeySym.uring] = Maia.Key.uring;
            s_Keysyms[global::Xcb.KeySym.udoubleacute] = Maia.Key.udoubleacute;
            s_Keysyms[global::Xcb.KeySym.tcedilla] = Maia.Key.tcedilla;
            s_Keysyms[global::Xcb.KeySym.abovedot] = Maia.Key.abovedot;
            s_Keysyms[global::Xcb.KeySym.Hstroke] = Maia.Key.Hstroke;
            s_Keysyms[global::Xcb.KeySym.Hcircumflex] = Maia.Key.Hcircumflex;
            s_Keysyms[global::Xcb.KeySym.Iabovedot] = Maia.Key.Iabovedot;
            s_Keysyms[global::Xcb.KeySym.Gbreve] = Maia.Key.Gbreve;
            s_Keysyms[global::Xcb.KeySym.Jcircumflex] = Maia.Key.Jcircumflex;
            s_Keysyms[global::Xcb.KeySym.hstroke] = Maia.Key.hstroke;
            s_Keysyms[global::Xcb.KeySym.hcircumflex] = Maia.Key.hcircumflex;
            s_Keysyms[global::Xcb.KeySym.idotless] = Maia.Key.idotless;
            s_Keysyms[global::Xcb.KeySym.gbreve] = Maia.Key.gbreve;
            s_Keysyms[global::Xcb.KeySym.jcircumflex] = Maia.Key.jcircumflex;
            s_Keysyms[global::Xcb.KeySym.Cabovedot] = Maia.Key.Cabovedot;
            s_Keysyms[global::Xcb.KeySym.Ccircumflex] = Maia.Key.Ccircumflex;
            s_Keysyms[global::Xcb.KeySym.Gabovedot] = Maia.Key.Gabovedot;
            s_Keysyms[global::Xcb.KeySym.Gcircumflex] = Maia.Key.Gcircumflex;
            s_Keysyms[global::Xcb.KeySym.Ubreve] = Maia.Key.Ubreve;
            s_Keysyms[global::Xcb.KeySym.Scircumflex] = Maia.Key.Scircumflex;
            s_Keysyms[global::Xcb.KeySym.cabovedot] = Maia.Key.cabovedot;
            s_Keysyms[global::Xcb.KeySym.ccircumflex] = Maia.Key.ccircumflex;
            s_Keysyms[global::Xcb.KeySym.gabovedot] = Maia.Key.gabovedot;
            s_Keysyms[global::Xcb.KeySym.gcircumflex] = Maia.Key.gcircumflex;
            s_Keysyms[global::Xcb.KeySym.ubreve] = Maia.Key.ubreve;
            s_Keysyms[global::Xcb.KeySym.scircumflex] = Maia.Key.scircumflex;
            s_Keysyms[global::Xcb.KeySym.kra] = Maia.Key.kra;
            s_Keysyms[global::Xcb.KeySym.kappa] = Maia.Key.kappa;
            s_Keysyms[global::Xcb.KeySym.Rcedilla] = Maia.Key.Rcedilla;
            s_Keysyms[global::Xcb.KeySym.Itilde] = Maia.Key.Itilde;
            s_Keysyms[global::Xcb.KeySym.Lcedilla] = Maia.Key.Lcedilla;
            s_Keysyms[global::Xcb.KeySym.Emacron] = Maia.Key.Emacron;
            s_Keysyms[global::Xcb.KeySym.Gcedilla] = Maia.Key.Gcedilla;
            s_Keysyms[global::Xcb.KeySym.Tslash] = Maia.Key.Tslash;
            s_Keysyms[global::Xcb.KeySym.rcedilla] = Maia.Key.rcedilla;
            s_Keysyms[global::Xcb.KeySym.itilde] = Maia.Key.itilde;
            s_Keysyms[global::Xcb.KeySym.lcedilla] = Maia.Key.lcedilla;
            s_Keysyms[global::Xcb.KeySym.emacron] = Maia.Key.emacron;
            s_Keysyms[global::Xcb.KeySym.gcedilla] = Maia.Key.gcedilla;
            s_Keysyms[global::Xcb.KeySym.tslash] = Maia.Key.tslash;
            s_Keysyms[global::Xcb.KeySym.ENG] = Maia.Key.ENG;
            s_Keysyms[global::Xcb.KeySym.eng] = Maia.Key.eng;
            s_Keysyms[global::Xcb.KeySym.Amacron] = Maia.Key.Amacron;
            s_Keysyms[global::Xcb.KeySym.Iogonek] = Maia.Key.Iogonek;
            s_Keysyms[global::Xcb.KeySym.Eabovedot] = Maia.Key.Eabovedot;
            s_Keysyms[global::Xcb.KeySym.Imacron] = Maia.Key.Imacron;
            s_Keysyms[global::Xcb.KeySym.Ncedilla] = Maia.Key.Ncedilla;
            s_Keysyms[global::Xcb.KeySym.Omacron] = Maia.Key.Omacron;
            s_Keysyms[global::Xcb.KeySym.Kcedilla] = Maia.Key.Kcedilla;
            s_Keysyms[global::Xcb.KeySym.Uogonek] = Maia.Key.Uogonek;
            s_Keysyms[global::Xcb.KeySym.Utilde] = Maia.Key.Utilde;
            s_Keysyms[global::Xcb.KeySym.Umacron] = Maia.Key.Umacron;
            s_Keysyms[global::Xcb.KeySym.amacron] = Maia.Key.amacron;
            s_Keysyms[global::Xcb.KeySym.iogonek] = Maia.Key.iogonek;
            s_Keysyms[global::Xcb.KeySym.eabovedot] = Maia.Key.eabovedot;
            s_Keysyms[global::Xcb.KeySym.imacron] = Maia.Key.imacron;
            s_Keysyms[global::Xcb.KeySym.ncedilla] = Maia.Key.ncedilla;
            s_Keysyms[global::Xcb.KeySym.omacron] = Maia.Key.omacron;
            s_Keysyms[global::Xcb.KeySym.kcedilla] = Maia.Key.kcedilla;
            s_Keysyms[global::Xcb.KeySym.uogonek] = Maia.Key.uogonek;
            s_Keysyms[global::Xcb.KeySym.utilde] = Maia.Key.utilde;
            s_Keysyms[global::Xcb.KeySym.umacron] = Maia.Key.umacron;
            s_Keysyms[global::Xcb.KeySym.Wcircumflex] = Maia.Key.Wcircumflex;
            s_Keysyms[global::Xcb.KeySym.wcircumflex] = Maia.Key.wcircumflex;
            s_Keysyms[global::Xcb.KeySym.Ycircumflex] = Maia.Key.Ycircumflex;
            s_Keysyms[global::Xcb.KeySym.ycircumflex] = Maia.Key.ycircumflex;
            s_Keysyms[global::Xcb.KeySym.Babovedot] = Maia.Key.Babovedot;
            s_Keysyms[global::Xcb.KeySym.babovedot] = Maia.Key.babovedot;
            s_Keysyms[global::Xcb.KeySym.Dabovedot] = Maia.Key.Dabovedot;
            s_Keysyms[global::Xcb.KeySym.dabovedot] = Maia.Key.dabovedot;
            s_Keysyms[global::Xcb.KeySym.Fabovedot] = Maia.Key.Fabovedot;
            s_Keysyms[global::Xcb.KeySym.fabovedot] = Maia.Key.fabovedot;
            s_Keysyms[global::Xcb.KeySym.Mabovedot] = Maia.Key.Mabovedot;
            s_Keysyms[global::Xcb.KeySym.mabovedot] = Maia.Key.mabovedot;
            s_Keysyms[global::Xcb.KeySym.Pabovedot] = Maia.Key.Pabovedot;
            s_Keysyms[global::Xcb.KeySym.pabovedot] = Maia.Key.pabovedot;
            s_Keysyms[global::Xcb.KeySym.Sabovedot] = Maia.Key.Sabovedot;
            s_Keysyms[global::Xcb.KeySym.sabovedot] = Maia.Key.sabovedot;
            s_Keysyms[global::Xcb.KeySym.Tabovedot] = Maia.Key.Tabovedot;
            s_Keysyms[global::Xcb.KeySym.tabovedot] = Maia.Key.tabovedot;
            s_Keysyms[global::Xcb.KeySym.Wgrave] = Maia.Key.Wgrave;
            s_Keysyms[global::Xcb.KeySym.wgrave] = Maia.Key.wgrave;
            s_Keysyms[global::Xcb.KeySym.Wacute] = Maia.Key.Wacute;
            s_Keysyms[global::Xcb.KeySym.wacute] = Maia.Key.wacute;
            s_Keysyms[global::Xcb.KeySym.Wdiaeresis] = Maia.Key.Wdiaeresis;
            s_Keysyms[global::Xcb.KeySym.wdiaeresis] = Maia.Key.wdiaeresis;
            s_Keysyms[global::Xcb.KeySym.Ygrave] = Maia.Key.Ygrave;
            s_Keysyms[global::Xcb.KeySym.ygrave] = Maia.Key.ygrave;
            s_Keysyms[global::Xcb.KeySym.OE] = Maia.Key.OE;
            s_Keysyms[global::Xcb.KeySym.oe] = Maia.Key.oe;
            s_Keysyms[global::Xcb.KeySym.Ydiaeresis] = Maia.Key.Ydiaeresis;
            s_Keysyms[global::Xcb.KeySym.overline] = Maia.Key.overline;
            s_Keysyms[global::Xcb.KeySym.kana_fullstop] = Maia.Key.kana_fullstop;
            s_Keysyms[global::Xcb.KeySym.kana_openingbracket] = Maia.Key.kana_openingbracket;
            s_Keysyms[global::Xcb.KeySym.kana_closingbracket] = Maia.Key.kana_closingbracket;
            s_Keysyms[global::Xcb.KeySym.kana_comma] = Maia.Key.kana_comma;
            s_Keysyms[global::Xcb.KeySym.kana_conjunctive] = Maia.Key.kana_conjunctive;
            s_Keysyms[global::Xcb.KeySym.kana_middledot] = Maia.Key.kana_middledot;
            s_Keysyms[global::Xcb.KeySym.kana_WO] = Maia.Key.kana_WO;
            s_Keysyms[global::Xcb.KeySym.kana_a] = Maia.Key.kana_a;
            s_Keysyms[global::Xcb.KeySym.kana_i] = Maia.Key.kana_i;
            s_Keysyms[global::Xcb.KeySym.kana_u] = Maia.Key.kana_u;
            s_Keysyms[global::Xcb.KeySym.kana_e] = Maia.Key.kana_e;
            s_Keysyms[global::Xcb.KeySym.kana_o] = Maia.Key.kana_o;
            s_Keysyms[global::Xcb.KeySym.kana_ya] = Maia.Key.kana_ya;
            s_Keysyms[global::Xcb.KeySym.kana_yu] = Maia.Key.kana_yu;
            s_Keysyms[global::Xcb.KeySym.kana_yo] = Maia.Key.kana_yo;
            s_Keysyms[global::Xcb.KeySym.kana_tsu] = Maia.Key.kana_tsu;
            s_Keysyms[global::Xcb.KeySym.kana_tu] = Maia.Key.kana_tu;
            s_Keysyms[global::Xcb.KeySym.prolongedsound] = Maia.Key.prolongedsound;
            s_Keysyms[global::Xcb.KeySym.kana_A] = Maia.Key.kana_A;
            s_Keysyms[global::Xcb.KeySym.kana_I] = Maia.Key.kana_I;
            s_Keysyms[global::Xcb.KeySym.kana_U] = Maia.Key.kana_U;
            s_Keysyms[global::Xcb.KeySym.kana_E] = Maia.Key.kana_E;
            s_Keysyms[global::Xcb.KeySym.kana_O] = Maia.Key.kana_O;
            s_Keysyms[global::Xcb.KeySym.kana_KA] = Maia.Key.kana_KA;
            s_Keysyms[global::Xcb.KeySym.kana_KI] = Maia.Key.kana_KI;
            s_Keysyms[global::Xcb.KeySym.kana_KU] = Maia.Key.kana_KU;
            s_Keysyms[global::Xcb.KeySym.kana_KE] = Maia.Key.kana_KE;
            s_Keysyms[global::Xcb.KeySym.kana_KO] = Maia.Key.kana_KO;
            s_Keysyms[global::Xcb.KeySym.kana_SA] = Maia.Key.kana_SA;
            s_Keysyms[global::Xcb.KeySym.kana_SHI] = Maia.Key.kana_SHI;
            s_Keysyms[global::Xcb.KeySym.kana_SU] = Maia.Key.kana_SU;
            s_Keysyms[global::Xcb.KeySym.kana_SE] = Maia.Key.kana_SE;
            s_Keysyms[global::Xcb.KeySym.kana_SO] = Maia.Key.kana_SO;
            s_Keysyms[global::Xcb.KeySym.kana_TA] = Maia.Key.kana_TA;
            s_Keysyms[global::Xcb.KeySym.kana_CHI] = Maia.Key.kana_CHI;
            s_Keysyms[global::Xcb.KeySym.kana_TI] = Maia.Key.kana_TI;
            s_Keysyms[global::Xcb.KeySym.kana_TSU] = Maia.Key.kana_TSU;
            s_Keysyms[global::Xcb.KeySym.kana_TU] = Maia.Key.kana_TU;
            s_Keysyms[global::Xcb.KeySym.kana_TE] = Maia.Key.kana_TE;
            s_Keysyms[global::Xcb.KeySym.kana_TO] = Maia.Key.kana_TO;
            s_Keysyms[global::Xcb.KeySym.kana_NA] = Maia.Key.kana_NA;
            s_Keysyms[global::Xcb.KeySym.kana_NI] = Maia.Key.kana_NI;
            s_Keysyms[global::Xcb.KeySym.kana_NU] = Maia.Key.kana_NU;
            s_Keysyms[global::Xcb.KeySym.kana_NE] = Maia.Key.kana_NE;
            s_Keysyms[global::Xcb.KeySym.kana_NO] = Maia.Key.kana_NO;
            s_Keysyms[global::Xcb.KeySym.kana_HA] = Maia.Key.kana_HA;
            s_Keysyms[global::Xcb.KeySym.kana_HI] = Maia.Key.kana_HI;
            s_Keysyms[global::Xcb.KeySym.kana_FU] = Maia.Key.kana_FU;
            s_Keysyms[global::Xcb.KeySym.kana_HU] = Maia.Key.kana_HU;
            s_Keysyms[global::Xcb.KeySym.kana_HE] = Maia.Key.kana_HE;
            s_Keysyms[global::Xcb.KeySym.kana_HO] = Maia.Key.kana_HO;
            s_Keysyms[global::Xcb.KeySym.kana_MA] = Maia.Key.kana_MA;
            s_Keysyms[global::Xcb.KeySym.kana_MI] = Maia.Key.kana_MI;
            s_Keysyms[global::Xcb.KeySym.kana_MU] = Maia.Key.kana_MU;
            s_Keysyms[global::Xcb.KeySym.kana_ME] = Maia.Key.kana_ME;
            s_Keysyms[global::Xcb.KeySym.kana_MO] = Maia.Key.kana_MO;
            s_Keysyms[global::Xcb.KeySym.kana_YA] = Maia.Key.kana_YA;
            s_Keysyms[global::Xcb.KeySym.kana_YU] = Maia.Key.kana_YU;
            s_Keysyms[global::Xcb.KeySym.kana_YO] = Maia.Key.kana_YO;
            s_Keysyms[global::Xcb.KeySym.kana_RA] = Maia.Key.kana_RA;
            s_Keysyms[global::Xcb.KeySym.kana_RI] = Maia.Key.kana_RI;
            s_Keysyms[global::Xcb.KeySym.kana_RU] = Maia.Key.kana_RU;
            s_Keysyms[global::Xcb.KeySym.kana_RE] = Maia.Key.kana_RE;
            s_Keysyms[global::Xcb.KeySym.kana_RO] = Maia.Key.kana_RO;
            s_Keysyms[global::Xcb.KeySym.kana_WA] = Maia.Key.kana_WA;
            s_Keysyms[global::Xcb.KeySym.kana_N] = Maia.Key.kana_N;
            s_Keysyms[global::Xcb.KeySym.voicedsound] = Maia.Key.voicedsound;
            s_Keysyms[global::Xcb.KeySym.semivoicedsound] = Maia.Key.semivoicedsound;
            s_Keysyms[global::Xcb.KeySym.kana_switch] = Maia.Key.kana_switch;
            s_Keysyms[global::Xcb.KeySym.Farsi_0] = Maia.Key.Farsi_0;
            s_Keysyms[global::Xcb.KeySym.Farsi_1] = Maia.Key.Farsi_1;
            s_Keysyms[global::Xcb.KeySym.Farsi_2] = Maia.Key.Farsi_2;
            s_Keysyms[global::Xcb.KeySym.Farsi_3] = Maia.Key.Farsi_3;
            s_Keysyms[global::Xcb.KeySym.Farsi_4] = Maia.Key.Farsi_4;
            s_Keysyms[global::Xcb.KeySym.Farsi_5] = Maia.Key.Farsi_5;
            s_Keysyms[global::Xcb.KeySym.Farsi_6] = Maia.Key.Farsi_6;
            s_Keysyms[global::Xcb.KeySym.Farsi_7] = Maia.Key.Farsi_7;
            s_Keysyms[global::Xcb.KeySym.Farsi_8] = Maia.Key.Farsi_8;
            s_Keysyms[global::Xcb.KeySym.Farsi_9] = Maia.Key.Farsi_9;
            s_Keysyms[global::Xcb.KeySym.Arabic_percent] = Maia.Key.Arabic_percent;
            s_Keysyms[global::Xcb.KeySym.Arabic_superscript_alef] = Maia.Key.Arabic_superscript_alef;
            s_Keysyms[global::Xcb.KeySym.Arabic_tteh] = Maia.Key.Arabic_tteh;
            s_Keysyms[global::Xcb.KeySym.Arabic_peh] = Maia.Key.Arabic_peh;
            s_Keysyms[global::Xcb.KeySym.Arabic_tcheh] = Maia.Key.Arabic_tcheh;
            s_Keysyms[global::Xcb.KeySym.Arabic_ddal] = Maia.Key.Arabic_ddal;
            s_Keysyms[global::Xcb.KeySym.Arabic_rreh] = Maia.Key.Arabic_rreh;
            s_Keysyms[global::Xcb.KeySym.Arabic_comma] = Maia.Key.Arabic_comma;
            s_Keysyms[global::Xcb.KeySym.Arabic_fullstop] = Maia.Key.Arabic_fullstop;
            s_Keysyms[global::Xcb.KeySym.Arabic_0] = Maia.Key.Arabic_0;
            s_Keysyms[global::Xcb.KeySym.Arabic_1] = Maia.Key.Arabic_1;
            s_Keysyms[global::Xcb.KeySym.Arabic_2] = Maia.Key.Arabic_2;
            s_Keysyms[global::Xcb.KeySym.Arabic_3] = Maia.Key.Arabic_3;
            s_Keysyms[global::Xcb.KeySym.Arabic_4] = Maia.Key.Arabic_4;
            s_Keysyms[global::Xcb.KeySym.Arabic_5] = Maia.Key.Arabic_5;
            s_Keysyms[global::Xcb.KeySym.Arabic_6] = Maia.Key.Arabic_6;
            s_Keysyms[global::Xcb.KeySym.Arabic_7] = Maia.Key.Arabic_7;
            s_Keysyms[global::Xcb.KeySym.Arabic_8] = Maia.Key.Arabic_8;
            s_Keysyms[global::Xcb.KeySym.Arabic_9] = Maia.Key.Arabic_9;
            s_Keysyms[global::Xcb.KeySym.Arabic_semicolon] = Maia.Key.Arabic_semicolon;
            s_Keysyms[global::Xcb.KeySym.Arabic_question_mark] = Maia.Key.Arabic_question_mark;
            s_Keysyms[global::Xcb.KeySym.Arabic_hamza] = Maia.Key.Arabic_hamza;
            s_Keysyms[global::Xcb.KeySym.Arabic_maddaonalef] = Maia.Key.Arabic_maddaonalef;
            s_Keysyms[global::Xcb.KeySym.Arabic_hamzaonalef] = Maia.Key.Arabic_hamzaonalef;
            s_Keysyms[global::Xcb.KeySym.Arabic_hamzaonwaw] = Maia.Key.Arabic_hamzaonwaw;
            s_Keysyms[global::Xcb.KeySym.Arabic_hamzaunderalef] = Maia.Key.Arabic_hamzaunderalef;
            s_Keysyms[global::Xcb.KeySym.Arabic_hamzaonyeh] = Maia.Key.Arabic_hamzaonyeh;
            s_Keysyms[global::Xcb.KeySym.Arabic_alef] = Maia.Key.Arabic_alef;
            s_Keysyms[global::Xcb.KeySym.Arabic_beh] = Maia.Key.Arabic_beh;
            s_Keysyms[global::Xcb.KeySym.Arabic_tehmarbuta] = Maia.Key.Arabic_tehmarbuta;
            s_Keysyms[global::Xcb.KeySym.Arabic_teh] = Maia.Key.Arabic_teh;
            s_Keysyms[global::Xcb.KeySym.Arabic_theh] = Maia.Key.Arabic_theh;
            s_Keysyms[global::Xcb.KeySym.Arabic_jeem] = Maia.Key.Arabic_jeem;
            s_Keysyms[global::Xcb.KeySym.Arabic_hah] = Maia.Key.Arabic_hah;
            s_Keysyms[global::Xcb.KeySym.Arabic_khah] = Maia.Key.Arabic_khah;
            s_Keysyms[global::Xcb.KeySym.Arabic_dal] = Maia.Key.Arabic_dal;
            s_Keysyms[global::Xcb.KeySym.Arabic_thal] = Maia.Key.Arabic_thal;
            s_Keysyms[global::Xcb.KeySym.Arabic_ra] = Maia.Key.Arabic_ra;
            s_Keysyms[global::Xcb.KeySym.Arabic_zain] = Maia.Key.Arabic_zain;
            s_Keysyms[global::Xcb.KeySym.Arabic_seen] = Maia.Key.Arabic_seen;
            s_Keysyms[global::Xcb.KeySym.Arabic_sheen] = Maia.Key.Arabic_sheen;
            s_Keysyms[global::Xcb.KeySym.Arabic_sad] = Maia.Key.Arabic_sad;
            s_Keysyms[global::Xcb.KeySym.Arabic_dad] = Maia.Key.Arabic_dad;
            s_Keysyms[global::Xcb.KeySym.Arabic_tah] = Maia.Key.Arabic_tah;
            s_Keysyms[global::Xcb.KeySym.Arabic_zah] = Maia.Key.Arabic_zah;
            s_Keysyms[global::Xcb.KeySym.Arabic_ain] = Maia.Key.Arabic_ain;
            s_Keysyms[global::Xcb.KeySym.Arabic_ghain] = Maia.Key.Arabic_ghain;
            s_Keysyms[global::Xcb.KeySym.Arabic_tatweel] = Maia.Key.Arabic_tatweel;
            s_Keysyms[global::Xcb.KeySym.Arabic_feh] = Maia.Key.Arabic_feh;
            s_Keysyms[global::Xcb.KeySym.Arabic_qaf] = Maia.Key.Arabic_qaf;
            s_Keysyms[global::Xcb.KeySym.Arabic_kaf] = Maia.Key.Arabic_kaf;
            s_Keysyms[global::Xcb.KeySym.Arabic_lam] = Maia.Key.Arabic_lam;
            s_Keysyms[global::Xcb.KeySym.Arabic_meem] = Maia.Key.Arabic_meem;
            s_Keysyms[global::Xcb.KeySym.Arabic_noon] = Maia.Key.Arabic_noon;
            s_Keysyms[global::Xcb.KeySym.Arabic_ha] = Maia.Key.Arabic_ha;
            s_Keysyms[global::Xcb.KeySym.Arabic_heh] = Maia.Key.Arabic_heh;
            s_Keysyms[global::Xcb.KeySym.Arabic_waw] = Maia.Key.Arabic_waw;
            s_Keysyms[global::Xcb.KeySym.Arabic_alefmaksura] = Maia.Key.Arabic_alefmaksura;
            s_Keysyms[global::Xcb.KeySym.Arabic_yeh] = Maia.Key.Arabic_yeh;
            s_Keysyms[global::Xcb.KeySym.Arabic_fathatan] = Maia.Key.Arabic_fathatan;
            s_Keysyms[global::Xcb.KeySym.Arabic_dammatan] = Maia.Key.Arabic_dammatan;
            s_Keysyms[global::Xcb.KeySym.Arabic_kasratan] = Maia.Key.Arabic_kasratan;
            s_Keysyms[global::Xcb.KeySym.Arabic_fatha] = Maia.Key.Arabic_fatha;
            s_Keysyms[global::Xcb.KeySym.Arabic_damma] = Maia.Key.Arabic_damma;
            s_Keysyms[global::Xcb.KeySym.Arabic_kasra] = Maia.Key.Arabic_kasra;
            s_Keysyms[global::Xcb.KeySym.Arabic_shadda] = Maia.Key.Arabic_shadda;
            s_Keysyms[global::Xcb.KeySym.Arabic_sukun] = Maia.Key.Arabic_sukun;
            s_Keysyms[global::Xcb.KeySym.Arabic_madda_above] = Maia.Key.Arabic_madda_above;
            s_Keysyms[global::Xcb.KeySym.Arabic_hamza_above] = Maia.Key.Arabic_hamza_above;
            s_Keysyms[global::Xcb.KeySym.Arabic_hamza_below] = Maia.Key.Arabic_hamza_below;
            s_Keysyms[global::Xcb.KeySym.Arabic_jeh] = Maia.Key.Arabic_jeh;
            s_Keysyms[global::Xcb.KeySym.Arabic_veh] = Maia.Key.Arabic_veh;
            s_Keysyms[global::Xcb.KeySym.Arabic_keheh] = Maia.Key.Arabic_keheh;
            s_Keysyms[global::Xcb.KeySym.Arabic_gaf] = Maia.Key.Arabic_gaf;
            s_Keysyms[global::Xcb.KeySym.Arabic_noon_ghunna] = Maia.Key.Arabic_noon_ghunna;
            s_Keysyms[global::Xcb.KeySym.Arabic_heh_doachashmee] = Maia.Key.Arabic_heh_doachashmee;
            s_Keysyms[global::Xcb.KeySym.Farsi_yeh] = Maia.Key.Farsi_yeh;
            s_Keysyms[global::Xcb.KeySym.Arabic_farsi_yeh] = Maia.Key.Arabic_farsi_yeh;
            s_Keysyms[global::Xcb.KeySym.Arabic_yeh_baree] = Maia.Key.Arabic_yeh_baree;
            s_Keysyms[global::Xcb.KeySym.Arabic_heh_goal] = Maia.Key.Arabic_heh_goal;
            s_Keysyms[global::Xcb.KeySym.Arabic_switch] = Maia.Key.Arabic_switch;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_GHE_bar] = Maia.Key.Cyrillic_GHE_bar;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ghe_bar] = Maia.Key.Cyrillic_ghe_bar;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ZHE_descender] = Maia.Key.Cyrillic_ZHE_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_zhe_descender] = Maia.Key.Cyrillic_zhe_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_KA_descender] = Maia.Key.Cyrillic_KA_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ka_descender] = Maia.Key.Cyrillic_ka_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_KA_vertstroke] = Maia.Key.Cyrillic_KA_vertstroke;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ka_vertstroke] = Maia.Key.Cyrillic_ka_vertstroke;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_EN_descender] = Maia.Key.Cyrillic_EN_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_en_descender] = Maia.Key.Cyrillic_en_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_U_straight] = Maia.Key.Cyrillic_U_straight;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_u_straight] = Maia.Key.Cyrillic_u_straight;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_U_straight_bar] = Maia.Key.Cyrillic_U_straight_bar;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_u_straight_bar] = Maia.Key.Cyrillic_u_straight_bar;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_HA_descender] = Maia.Key.Cyrillic_HA_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ha_descender] = Maia.Key.Cyrillic_ha_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_CHE_descender] = Maia.Key.Cyrillic_CHE_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_che_descender] = Maia.Key.Cyrillic_che_descender;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_CHE_vertstroke] = Maia.Key.Cyrillic_CHE_vertstroke;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_che_vertstroke] = Maia.Key.Cyrillic_che_vertstroke;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_SHHA] = Maia.Key.Cyrillic_SHHA;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_shha] = Maia.Key.Cyrillic_shha;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_SCHWA] = Maia.Key.Cyrillic_SCHWA;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_schwa] = Maia.Key.Cyrillic_schwa;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_I_macron] = Maia.Key.Cyrillic_I_macron;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_i_macron] = Maia.Key.Cyrillic_i_macron;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_O_bar] = Maia.Key.Cyrillic_O_bar;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_o_bar] = Maia.Key.Cyrillic_o_bar;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_U_macron] = Maia.Key.Cyrillic_U_macron;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_u_macron] = Maia.Key.Cyrillic_u_macron;
            s_Keysyms[global::Xcb.KeySym.Serbian_dje] = Maia.Key.Serbian_dje;
            s_Keysyms[global::Xcb.KeySym.Macedonia_gje] = Maia.Key.Macedonia_gje;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_io] = Maia.Key.Cyrillic_io;
            s_Keysyms[global::Xcb.KeySym.Ukrainian_ie] = Maia.Key.Ukrainian_ie;
            s_Keysyms[global::Xcb.KeySym.Ukranian_je] = Maia.Key.Ukranian_je;
            s_Keysyms[global::Xcb.KeySym.Macedonia_dse] = Maia.Key.Macedonia_dse;
            s_Keysyms[global::Xcb.KeySym.Ukrainian_i] = Maia.Key.Ukrainian_i;
            s_Keysyms[global::Xcb.KeySym.Ukranian_i] = Maia.Key.Ukranian_i;
            s_Keysyms[global::Xcb.KeySym.Ukrainian_yi] = Maia.Key.Ukrainian_yi;
            s_Keysyms[global::Xcb.KeySym.Ukranian_yi] = Maia.Key.Ukranian_yi;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_je] = Maia.Key.Cyrillic_je;
            s_Keysyms[global::Xcb.KeySym.Serbian_je] = Maia.Key.Serbian_je;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_lje] = Maia.Key.Cyrillic_lje;
            s_Keysyms[global::Xcb.KeySym.Serbian_lje] = Maia.Key.Serbian_lje;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_nje] = Maia.Key.Cyrillic_nje;
            s_Keysyms[global::Xcb.KeySym.Serbian_nje] = Maia.Key.Serbian_nje;
            s_Keysyms[global::Xcb.KeySym.Serbian_tshe] = Maia.Key.Serbian_tshe;
            s_Keysyms[global::Xcb.KeySym.Macedonia_kje] = Maia.Key.Macedonia_kje;
            s_Keysyms[global::Xcb.KeySym.Ukrainian_ghe_with_upturn] = Maia.Key.Ukrainian_ghe_with_upturn;
            s_Keysyms[global::Xcb.KeySym.Byelorussian_shortu] = Maia.Key.Byelorussian_shortu;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_dzhe] = Maia.Key.Cyrillic_dzhe;
            s_Keysyms[global::Xcb.KeySym.Serbian_dze] = Maia.Key.Serbian_dze;
            s_Keysyms[global::Xcb.KeySym.numerosign] = Maia.Key.numerosign;
            s_Keysyms[global::Xcb.KeySym.Serbian_DJE] = Maia.Key.Serbian_DJE;
            s_Keysyms[global::Xcb.KeySym.Macedonia_GJE] = Maia.Key.Macedonia_GJE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_IO] = Maia.Key.Cyrillic_IO;
            s_Keysyms[global::Xcb.KeySym.Ukrainian_IE] = Maia.Key.Ukrainian_IE;
            s_Keysyms[global::Xcb.KeySym.Ukranian_JE] = Maia.Key.Ukranian_JE;
            s_Keysyms[global::Xcb.KeySym.Macedonia_DSE] = Maia.Key.Macedonia_DSE;
            s_Keysyms[global::Xcb.KeySym.Ukrainian_I] = Maia.Key.Ukrainian_I;
            s_Keysyms[global::Xcb.KeySym.Ukranian_I] = Maia.Key.Ukranian_I;
            s_Keysyms[global::Xcb.KeySym.Ukrainian_YI] = Maia.Key.Ukrainian_YI;
            s_Keysyms[global::Xcb.KeySym.Ukranian_YI] = Maia.Key.Ukranian_YI;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_JE] = Maia.Key.Cyrillic_JE;
            s_Keysyms[global::Xcb.KeySym.Serbian_JE] = Maia.Key.Serbian_JE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_LJE] = Maia.Key.Cyrillic_LJE;
            s_Keysyms[global::Xcb.KeySym.Serbian_LJE] = Maia.Key.Serbian_LJE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_NJE] = Maia.Key.Cyrillic_NJE;
            s_Keysyms[global::Xcb.KeySym.Serbian_NJE] = Maia.Key.Serbian_NJE;
            s_Keysyms[global::Xcb.KeySym.Serbian_TSHE] = Maia.Key.Serbian_TSHE;
            s_Keysyms[global::Xcb.KeySym.Macedonia_KJE] = Maia.Key.Macedonia_KJE;
            s_Keysyms[global::Xcb.KeySym.Ukrainian_GHE_WITH_UPTURN] = Maia.Key.Ukrainian_GHE_WITH_UPTURN;
            s_Keysyms[global::Xcb.KeySym.Byelorussian_SHORTU] = Maia.Key.Byelorussian_SHORTU;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_DZHE] = Maia.Key.Cyrillic_DZHE;
            s_Keysyms[global::Xcb.KeySym.Serbian_DZE] = Maia.Key.Serbian_DZE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_yu] = Maia.Key.Cyrillic_yu;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_a] = Maia.Key.Cyrillic_a;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_be] = Maia.Key.Cyrillic_be;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_tse] = Maia.Key.Cyrillic_tse;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_de] = Maia.Key.Cyrillic_de;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ie] = Maia.Key.Cyrillic_ie;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ef] = Maia.Key.Cyrillic_ef;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ghe] = Maia.Key.Cyrillic_ghe;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ha] = Maia.Key.Cyrillic_ha;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_i] = Maia.Key.Cyrillic_i;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_shorti] = Maia.Key.Cyrillic_shorti;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ka] = Maia.Key.Cyrillic_ka;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_el] = Maia.Key.Cyrillic_el;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_em] = Maia.Key.Cyrillic_em;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_en] = Maia.Key.Cyrillic_en;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_o] = Maia.Key.Cyrillic_o;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_pe] = Maia.Key.Cyrillic_pe;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ya] = Maia.Key.Cyrillic_ya;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_er] = Maia.Key.Cyrillic_er;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_es] = Maia.Key.Cyrillic_es;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_te] = Maia.Key.Cyrillic_te;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_u] = Maia.Key.Cyrillic_u;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_zhe] = Maia.Key.Cyrillic_zhe;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ve] = Maia.Key.Cyrillic_ve;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_softsign] = Maia.Key.Cyrillic_softsign;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_yeru] = Maia.Key.Cyrillic_yeru;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ze] = Maia.Key.Cyrillic_ze;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_sha] = Maia.Key.Cyrillic_sha;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_e] = Maia.Key.Cyrillic_e;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_shcha] = Maia.Key.Cyrillic_shcha;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_che] = Maia.Key.Cyrillic_che;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_hardsign] = Maia.Key.Cyrillic_hardsign;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_YU] = Maia.Key.Cyrillic_YU;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_A] = Maia.Key.Cyrillic_A;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_BE] = Maia.Key.Cyrillic_BE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_TSE] = Maia.Key.Cyrillic_TSE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_DE] = Maia.Key.Cyrillic_DE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_IE] = Maia.Key.Cyrillic_IE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_EF] = Maia.Key.Cyrillic_EF;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_GHE] = Maia.Key.Cyrillic_GHE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_HA] = Maia.Key.Cyrillic_HA;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_I] = Maia.Key.Cyrillic_I;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_SHORTI] = Maia.Key.Cyrillic_SHORTI;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_KA] = Maia.Key.Cyrillic_KA;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_EL] = Maia.Key.Cyrillic_EL;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_EM] = Maia.Key.Cyrillic_EM;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_EN] = Maia.Key.Cyrillic_EN;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_O] = Maia.Key.Cyrillic_O;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_PE] = Maia.Key.Cyrillic_PE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_YA] = Maia.Key.Cyrillic_YA;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ER] = Maia.Key.Cyrillic_ER;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ES] = Maia.Key.Cyrillic_ES;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_TE] = Maia.Key.Cyrillic_TE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_U] = Maia.Key.Cyrillic_U;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ZHE] = Maia.Key.Cyrillic_ZHE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_VE] = Maia.Key.Cyrillic_VE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_SOFTSIGN] = Maia.Key.Cyrillic_SOFTSIGN;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_YERU] = Maia.Key.Cyrillic_YERU;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_ZE] = Maia.Key.Cyrillic_ZE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_SHA] = Maia.Key.Cyrillic_SHA;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_E] = Maia.Key.Cyrillic_E;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_SHCHA] = Maia.Key.Cyrillic_SHCHA;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_CHE] = Maia.Key.Cyrillic_CHE;
            s_Keysyms[global::Xcb.KeySym.Cyrillic_HARDSIGN] = Maia.Key.Cyrillic_HARDSIGN;
            s_Keysyms[global::Xcb.KeySym.Greek_ALPHAaccent] = Maia.Key.Greek_ALPHAaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_EPSILONaccent] = Maia.Key.Greek_EPSILONaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_ETAaccent] = Maia.Key.Greek_ETAaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_IOTAaccent] = Maia.Key.Greek_IOTAaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_IOTAdieresis] = Maia.Key.Greek_IOTAdieresis;
            s_Keysyms[global::Xcb.KeySym.Greek_IOTAdiaeresis] = Maia.Key.Greek_IOTAdiaeresis;
            s_Keysyms[global::Xcb.KeySym.Greek_OMICRONaccent] = Maia.Key.Greek_OMICRONaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_UPSILONaccent] = Maia.Key.Greek_UPSILONaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_UPSILONdieresis] = Maia.Key.Greek_UPSILONdieresis;
            s_Keysyms[global::Xcb.KeySym.Greek_OMEGAaccent] = Maia.Key.Greek_OMEGAaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_accentdieresis] = Maia.Key.Greek_accentdieresis;
            s_Keysyms[global::Xcb.KeySym.Greek_horizbar] = Maia.Key.Greek_horizbar;
            s_Keysyms[global::Xcb.KeySym.Greek_alphaaccent] = Maia.Key.Greek_alphaaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_epsilonaccent] = Maia.Key.Greek_epsilonaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_etaaccent] = Maia.Key.Greek_etaaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_iotaaccent] = Maia.Key.Greek_iotaaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_iotadieresis] = Maia.Key.Greek_iotadieresis;
            s_Keysyms[global::Xcb.KeySym.Greek_iotaaccentdieresis] = Maia.Key.Greek_iotaaccentdieresis;
            s_Keysyms[global::Xcb.KeySym.Greek_omicronaccent] = Maia.Key.Greek_omicronaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_upsilonaccent] = Maia.Key.Greek_upsilonaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_upsilondieresis] = Maia.Key.Greek_upsilondieresis;
            s_Keysyms[global::Xcb.KeySym.Greek_upsilonaccentdieresis] = Maia.Key.Greek_upsilonaccentdieresis;
            s_Keysyms[global::Xcb.KeySym.Greek_omegaaccent] = Maia.Key.Greek_omegaaccent;
            s_Keysyms[global::Xcb.KeySym.Greek_ALPHA] = Maia.Key.Greek_ALPHA;
            s_Keysyms[global::Xcb.KeySym.Greek_BETA] = Maia.Key.Greek_BETA;
            s_Keysyms[global::Xcb.KeySym.Greek_GAMMA] = Maia.Key.Greek_GAMMA;
            s_Keysyms[global::Xcb.KeySym.Greek_DELTA] = Maia.Key.Greek_DELTA;
            s_Keysyms[global::Xcb.KeySym.Greek_EPSILON] = Maia.Key.Greek_EPSILON;
            s_Keysyms[global::Xcb.KeySym.Greek_ZETA] = Maia.Key.Greek_ZETA;
            s_Keysyms[global::Xcb.KeySym.Greek_ETA] = Maia.Key.Greek_ETA;
            s_Keysyms[global::Xcb.KeySym.Greek_THETA] = Maia.Key.Greek_THETA;
            s_Keysyms[global::Xcb.KeySym.Greek_IOTA] = Maia.Key.Greek_IOTA;
            s_Keysyms[global::Xcb.KeySym.Greek_KAPPA] = Maia.Key.Greek_KAPPA;
            s_Keysyms[global::Xcb.KeySym.Greek_LAMDA] = Maia.Key.Greek_LAMDA;
            s_Keysyms[global::Xcb.KeySym.Greek_LAMBDA] = Maia.Key.Greek_LAMBDA;
            s_Keysyms[global::Xcb.KeySym.Greek_MU] = Maia.Key.Greek_MU;
            s_Keysyms[global::Xcb.KeySym.Greek_NU] = Maia.Key.Greek_NU;
            s_Keysyms[global::Xcb.KeySym.Greek_XI] = Maia.Key.Greek_XI;
            s_Keysyms[global::Xcb.KeySym.Greek_OMICRON] = Maia.Key.Greek_OMICRON;
            s_Keysyms[global::Xcb.KeySym.Greek_PI] = Maia.Key.Greek_PI;
            s_Keysyms[global::Xcb.KeySym.Greek_RHO] = Maia.Key.Greek_RHO;
            s_Keysyms[global::Xcb.KeySym.Greek_SIGMA] = Maia.Key.Greek_SIGMA;
            s_Keysyms[global::Xcb.KeySym.Greek_TAU] = Maia.Key.Greek_TAU;
            s_Keysyms[global::Xcb.KeySym.Greek_UPSILON] = Maia.Key.Greek_UPSILON;
            s_Keysyms[global::Xcb.KeySym.Greek_PHI] = Maia.Key.Greek_PHI;
            s_Keysyms[global::Xcb.KeySym.Greek_CHI] = Maia.Key.Greek_CHI;
            s_Keysyms[global::Xcb.KeySym.Greek_PSI] = Maia.Key.Greek_PSI;
            s_Keysyms[global::Xcb.KeySym.Greek_OMEGA] = Maia.Key.Greek_OMEGA;
            s_Keysyms[global::Xcb.KeySym.Greek_alpha] = Maia.Key.Greek_alpha;
            s_Keysyms[global::Xcb.KeySym.Greek_beta] = Maia.Key.Greek_beta;
            s_Keysyms[global::Xcb.KeySym.Greek_gamma] = Maia.Key.Greek_gamma;
            s_Keysyms[global::Xcb.KeySym.Greek_delta] = Maia.Key.Greek_delta;
            s_Keysyms[global::Xcb.KeySym.Greek_epsilon] = Maia.Key.Greek_epsilon;
            s_Keysyms[global::Xcb.KeySym.Greek_zeta] = Maia.Key.Greek_zeta;
            s_Keysyms[global::Xcb.KeySym.Greek_eta] = Maia.Key.Greek_eta;
            s_Keysyms[global::Xcb.KeySym.Greek_theta] = Maia.Key.Greek_theta;
            s_Keysyms[global::Xcb.KeySym.Greek_iota] = Maia.Key.Greek_iota;
            s_Keysyms[global::Xcb.KeySym.Greek_kappa] = Maia.Key.Greek_kappa;
            s_Keysyms[global::Xcb.KeySym.Greek_lamda] = Maia.Key.Greek_lamda;
            s_Keysyms[global::Xcb.KeySym.Greek_lambda] = Maia.Key.Greek_lambda;
            s_Keysyms[global::Xcb.KeySym.Greek_mu] = Maia.Key.Greek_mu;
            s_Keysyms[global::Xcb.KeySym.Greek_nu] = Maia.Key.Greek_nu;
            s_Keysyms[global::Xcb.KeySym.Greek_xi] = Maia.Key.Greek_xi;
            s_Keysyms[global::Xcb.KeySym.Greek_omicron] = Maia.Key.Greek_omicron;
            s_Keysyms[global::Xcb.KeySym.Greek_pi] = Maia.Key.Greek_pi;
            s_Keysyms[global::Xcb.KeySym.Greek_rho] = Maia.Key.Greek_rho;
            s_Keysyms[global::Xcb.KeySym.Greek_sigma] = Maia.Key.Greek_sigma;
            s_Keysyms[global::Xcb.KeySym.Greek_finalsmallsigma] = Maia.Key.Greek_finalsmallsigma;
            s_Keysyms[global::Xcb.KeySym.Greek_tau] = Maia.Key.Greek_tau;
            s_Keysyms[global::Xcb.KeySym.Greek_upsilon] = Maia.Key.Greek_upsilon;
            s_Keysyms[global::Xcb.KeySym.Greek_phi] = Maia.Key.Greek_phi;
            s_Keysyms[global::Xcb.KeySym.Greek_chi] = Maia.Key.Greek_chi;
            s_Keysyms[global::Xcb.KeySym.Greek_psi] = Maia.Key.Greek_psi;
            s_Keysyms[global::Xcb.KeySym.Greek_omega] = Maia.Key.Greek_omega;
            s_Keysyms[global::Xcb.KeySym.Greek_switch] = Maia.Key.Greek_switch;
            s_Keysyms[global::Xcb.KeySym.hebrew_doublelowline] = Maia.Key.hebrew_doublelowline;
            s_Keysyms[global::Xcb.KeySym.hebrew_aleph] = Maia.Key.hebrew_aleph;
            s_Keysyms[global::Xcb.KeySym.hebrew_bet] = Maia.Key.hebrew_bet;
            s_Keysyms[global::Xcb.KeySym.hebrew_beth] = Maia.Key.hebrew_beth;
            s_Keysyms[global::Xcb.KeySym.hebrew_gimel] = Maia.Key.hebrew_gimel;
            s_Keysyms[global::Xcb.KeySym.hebrew_gimmel] = Maia.Key.hebrew_gimmel;
            s_Keysyms[global::Xcb.KeySym.hebrew_dalet] = Maia.Key.hebrew_dalet;
            s_Keysyms[global::Xcb.KeySym.hebrew_daleth] = Maia.Key.hebrew_daleth;
            s_Keysyms[global::Xcb.KeySym.hebrew_he] = Maia.Key.hebrew_he;
            s_Keysyms[global::Xcb.KeySym.hebrew_waw] = Maia.Key.hebrew_waw;
            s_Keysyms[global::Xcb.KeySym.hebrew_zain] = Maia.Key.hebrew_zain;
            s_Keysyms[global::Xcb.KeySym.hebrew_zayin] = Maia.Key.hebrew_zayin;
            s_Keysyms[global::Xcb.KeySym.hebrew_chet] = Maia.Key.hebrew_chet;
            s_Keysyms[global::Xcb.KeySym.hebrew_het] = Maia.Key.hebrew_het;
            s_Keysyms[global::Xcb.KeySym.hebrew_tet] = Maia.Key.hebrew_tet;
            s_Keysyms[global::Xcb.KeySym.hebrew_teth] = Maia.Key.hebrew_teth;
            s_Keysyms[global::Xcb.KeySym.hebrew_yod] = Maia.Key.hebrew_yod;
            s_Keysyms[global::Xcb.KeySym.hebrew_finalkaph] = Maia.Key.hebrew_finalkaph;
            s_Keysyms[global::Xcb.KeySym.hebrew_kaph] = Maia.Key.hebrew_kaph;
            s_Keysyms[global::Xcb.KeySym.hebrew_lamed] = Maia.Key.hebrew_lamed;
            s_Keysyms[global::Xcb.KeySym.hebrew_finalmem] = Maia.Key.hebrew_finalmem;
            s_Keysyms[global::Xcb.KeySym.hebrew_mem] = Maia.Key.hebrew_mem;
            s_Keysyms[global::Xcb.KeySym.hebrew_finalnun] = Maia.Key.hebrew_finalnun;
            s_Keysyms[global::Xcb.KeySym.hebrew_nun] = Maia.Key.hebrew_nun;
            s_Keysyms[global::Xcb.KeySym.hebrew_samech] = Maia.Key.hebrew_samech;
            s_Keysyms[global::Xcb.KeySym.hebrew_samekh] = Maia.Key.hebrew_samekh;
            s_Keysyms[global::Xcb.KeySym.hebrew_ayin] = Maia.Key.hebrew_ayin;
            s_Keysyms[global::Xcb.KeySym.hebrew_finalpe] = Maia.Key.hebrew_finalpe;
            s_Keysyms[global::Xcb.KeySym.hebrew_pe] = Maia.Key.hebrew_pe;
            s_Keysyms[global::Xcb.KeySym.hebrew_finalzade] = Maia.Key.hebrew_finalzade;
            s_Keysyms[global::Xcb.KeySym.hebrew_finalzadi] = Maia.Key.hebrew_finalzadi;
            s_Keysyms[global::Xcb.KeySym.hebrew_zade] = Maia.Key.hebrew_zade;
            s_Keysyms[global::Xcb.KeySym.hebrew_zadi] = Maia.Key.hebrew_zadi;
            s_Keysyms[global::Xcb.KeySym.hebrew_qoph] = Maia.Key.hebrew_qoph;
            s_Keysyms[global::Xcb.KeySym.hebrew_kuf] = Maia.Key.hebrew_kuf;
            s_Keysyms[global::Xcb.KeySym.hebrew_resh] = Maia.Key.hebrew_resh;
            s_Keysyms[global::Xcb.KeySym.hebrew_shin] = Maia.Key.hebrew_shin;
            s_Keysyms[global::Xcb.KeySym.hebrew_taw] = Maia.Key.hebrew_taw;
            s_Keysyms[global::Xcb.KeySym.hebrew_taf] = Maia.Key.hebrew_taf;
            s_Keysyms[global::Xcb.KeySym.Hebrew_switch] = Maia.Key.Hebrew_switch;
            s_Keysyms[global::Xcb.KeySym.Thai_kokai] = Maia.Key.Thai_kokai;
            s_Keysyms[global::Xcb.KeySym.Thai_khokhai] = Maia.Key.Thai_khokhai;
            s_Keysyms[global::Xcb.KeySym.Thai_khokhuat] = Maia.Key.Thai_khokhuat;
            s_Keysyms[global::Xcb.KeySym.Thai_khokhwai] = Maia.Key.Thai_khokhwai;
            s_Keysyms[global::Xcb.KeySym.Thai_khokhon] = Maia.Key.Thai_khokhon;
            s_Keysyms[global::Xcb.KeySym.Thai_khorakhang] = Maia.Key.Thai_khorakhang;
            s_Keysyms[global::Xcb.KeySym.Thai_ngongu] = Maia.Key.Thai_ngongu;
            s_Keysyms[global::Xcb.KeySym.Thai_chochan] = Maia.Key.Thai_chochan;
            s_Keysyms[global::Xcb.KeySym.Thai_choching] = Maia.Key.Thai_choching;
            s_Keysyms[global::Xcb.KeySym.Thai_chochang] = Maia.Key.Thai_chochang;
            s_Keysyms[global::Xcb.KeySym.Thai_soso] = Maia.Key.Thai_soso;
            s_Keysyms[global::Xcb.KeySym.Thai_chochoe] = Maia.Key.Thai_chochoe;
            s_Keysyms[global::Xcb.KeySym.Thai_yoying] = Maia.Key.Thai_yoying;
            s_Keysyms[global::Xcb.KeySym.Thai_dochada] = Maia.Key.Thai_dochada;
            s_Keysyms[global::Xcb.KeySym.Thai_topatak] = Maia.Key.Thai_topatak;
            s_Keysyms[global::Xcb.KeySym.Thai_thothan] = Maia.Key.Thai_thothan;
            s_Keysyms[global::Xcb.KeySym.Thai_thonangmontho] = Maia.Key.Thai_thonangmontho;
            s_Keysyms[global::Xcb.KeySym.Thai_thophuthao] = Maia.Key.Thai_thophuthao;
            s_Keysyms[global::Xcb.KeySym.Thai_nonen] = Maia.Key.Thai_nonen;
            s_Keysyms[global::Xcb.KeySym.Thai_dodek] = Maia.Key.Thai_dodek;
            s_Keysyms[global::Xcb.KeySym.Thai_totao] = Maia.Key.Thai_totao;
            s_Keysyms[global::Xcb.KeySym.Thai_thothung] = Maia.Key.Thai_thothung;
            s_Keysyms[global::Xcb.KeySym.Thai_thothahan] = Maia.Key.Thai_thothahan;
            s_Keysyms[global::Xcb.KeySym.Thai_thothong] = Maia.Key.Thai_thothong;
            s_Keysyms[global::Xcb.KeySym.Thai_nonu] = Maia.Key.Thai_nonu;
            s_Keysyms[global::Xcb.KeySym.Thai_bobaimai] = Maia.Key.Thai_bobaimai;
            s_Keysyms[global::Xcb.KeySym.Thai_popla] = Maia.Key.Thai_popla;
            s_Keysyms[global::Xcb.KeySym.Thai_phophung] = Maia.Key.Thai_phophung;
            s_Keysyms[global::Xcb.KeySym.Thai_fofa] = Maia.Key.Thai_fofa;
            s_Keysyms[global::Xcb.KeySym.Thai_phophan] = Maia.Key.Thai_phophan;
            s_Keysyms[global::Xcb.KeySym.Thai_fofan] = Maia.Key.Thai_fofan;
            s_Keysyms[global::Xcb.KeySym.Thai_phosamphao] = Maia.Key.Thai_phosamphao;
            s_Keysyms[global::Xcb.KeySym.Thai_moma] = Maia.Key.Thai_moma;
            s_Keysyms[global::Xcb.KeySym.Thai_yoyak] = Maia.Key.Thai_yoyak;
            s_Keysyms[global::Xcb.KeySym.Thai_rorua] = Maia.Key.Thai_rorua;
            s_Keysyms[global::Xcb.KeySym.Thai_ru] = Maia.Key.Thai_ru;
            s_Keysyms[global::Xcb.KeySym.Thai_loling] = Maia.Key.Thai_loling;
            s_Keysyms[global::Xcb.KeySym.Thai_lu] = Maia.Key.Thai_lu;
            s_Keysyms[global::Xcb.KeySym.Thai_wowaen] = Maia.Key.Thai_wowaen;
            s_Keysyms[global::Xcb.KeySym.Thai_sosala] = Maia.Key.Thai_sosala;
            s_Keysyms[global::Xcb.KeySym.Thai_sorusi] = Maia.Key.Thai_sorusi;
            s_Keysyms[global::Xcb.KeySym.Thai_sosua] = Maia.Key.Thai_sosua;
            s_Keysyms[global::Xcb.KeySym.Thai_hohip] = Maia.Key.Thai_hohip;
            s_Keysyms[global::Xcb.KeySym.Thai_lochula] = Maia.Key.Thai_lochula;
            s_Keysyms[global::Xcb.KeySym.Thai_oang] = Maia.Key.Thai_oang;
            s_Keysyms[global::Xcb.KeySym.Thai_honokhuk] = Maia.Key.Thai_honokhuk;
            s_Keysyms[global::Xcb.KeySym.Thai_paiyannoi] = Maia.Key.Thai_paiyannoi;
            s_Keysyms[global::Xcb.KeySym.Thai_saraa] = Maia.Key.Thai_saraa;
            s_Keysyms[global::Xcb.KeySym.Thai_maihanakat] = Maia.Key.Thai_maihanakat;
            s_Keysyms[global::Xcb.KeySym.Thai_saraaa] = Maia.Key.Thai_saraaa;
            s_Keysyms[global::Xcb.KeySym.Thai_saraam] = Maia.Key.Thai_saraam;
            s_Keysyms[global::Xcb.KeySym.Thai_sarai] = Maia.Key.Thai_sarai;
            s_Keysyms[global::Xcb.KeySym.Thai_saraii] = Maia.Key.Thai_saraii;
            s_Keysyms[global::Xcb.KeySym.Thai_saraue] = Maia.Key.Thai_saraue;
            s_Keysyms[global::Xcb.KeySym.Thai_sarauee] = Maia.Key.Thai_sarauee;
            s_Keysyms[global::Xcb.KeySym.Thai_sarau] = Maia.Key.Thai_sarau;
            s_Keysyms[global::Xcb.KeySym.Thai_sarauu] = Maia.Key.Thai_sarauu;
            s_Keysyms[global::Xcb.KeySym.Thai_phinthu] = Maia.Key.Thai_phinthu;
            s_Keysyms[global::Xcb.KeySym.Thai_maihanakat_maitho] = Maia.Key.Thai_maihanakat_maitho;
            s_Keysyms[global::Xcb.KeySym.Thai_baht] = Maia.Key.Thai_baht;
            s_Keysyms[global::Xcb.KeySym.Thai_sarae] = Maia.Key.Thai_sarae;
            s_Keysyms[global::Xcb.KeySym.Thai_saraae] = Maia.Key.Thai_saraae;
            s_Keysyms[global::Xcb.KeySym.Thai_sarao] = Maia.Key.Thai_sarao;
            s_Keysyms[global::Xcb.KeySym.Thai_saraaimaimuan] = Maia.Key.Thai_saraaimaimuan;
            s_Keysyms[global::Xcb.KeySym.Thai_saraaimaimalai] = Maia.Key.Thai_saraaimaimalai;
            s_Keysyms[global::Xcb.KeySym.Thai_lakkhangyao] = Maia.Key.Thai_lakkhangyao;
            s_Keysyms[global::Xcb.KeySym.Thai_maiyamok] = Maia.Key.Thai_maiyamok;
            s_Keysyms[global::Xcb.KeySym.Thai_maitaikhu] = Maia.Key.Thai_maitaikhu;
            s_Keysyms[global::Xcb.KeySym.Thai_maiek] = Maia.Key.Thai_maiek;
            s_Keysyms[global::Xcb.KeySym.Thai_maitho] = Maia.Key.Thai_maitho;
            s_Keysyms[global::Xcb.KeySym.Thai_maitri] = Maia.Key.Thai_maitri;
            s_Keysyms[global::Xcb.KeySym.Thai_maichattawa] = Maia.Key.Thai_maichattawa;
            s_Keysyms[global::Xcb.KeySym.Thai_thanthakhat] = Maia.Key.Thai_thanthakhat;
            s_Keysyms[global::Xcb.KeySym.Thai_nikhahit] = Maia.Key.Thai_nikhahit;
            s_Keysyms[global::Xcb.KeySym.Thai_leksun] = Maia.Key.Thai_leksun;
            s_Keysyms[global::Xcb.KeySym.Thai_leknung] = Maia.Key.Thai_leknung;
            s_Keysyms[global::Xcb.KeySym.Thai_leksong] = Maia.Key.Thai_leksong;
            s_Keysyms[global::Xcb.KeySym.Thai_leksam] = Maia.Key.Thai_leksam;
            s_Keysyms[global::Xcb.KeySym.Thai_leksi] = Maia.Key.Thai_leksi;
            s_Keysyms[global::Xcb.KeySym.Thai_lekha] = Maia.Key.Thai_lekha;
            s_Keysyms[global::Xcb.KeySym.Thai_lekhok] = Maia.Key.Thai_lekhok;
            s_Keysyms[global::Xcb.KeySym.Thai_lekchet] = Maia.Key.Thai_lekchet;
            s_Keysyms[global::Xcb.KeySym.Thai_lekpaet] = Maia.Key.Thai_lekpaet;
            s_Keysyms[global::Xcb.KeySym.Thai_lekkao] = Maia.Key.Thai_lekkao;
            s_Keysyms[global::Xcb.KeySym.Hangul] = Maia.Key.Hangul;
            s_Keysyms[global::Xcb.KeySym.Hangul_Start] = Maia.Key.Hangul_Start;
            s_Keysyms[global::Xcb.KeySym.Hangul_End] = Maia.Key.Hangul_End;
            s_Keysyms[global::Xcb.KeySym.Hangul_Hanja] = Maia.Key.Hangul_Hanja;
            s_Keysyms[global::Xcb.KeySym.Hangul_Jamo] = Maia.Key.Hangul_Jamo;
            s_Keysyms[global::Xcb.KeySym.Hangul_Romaja] = Maia.Key.Hangul_Romaja;
            s_Keysyms[global::Xcb.KeySym.Hangul_Codeinput] = Maia.Key.Hangul_Codeinput;
            s_Keysyms[global::Xcb.KeySym.Hangul_Jeonja] = Maia.Key.Hangul_Jeonja;
            s_Keysyms[global::Xcb.KeySym.Hangul_Banja] = Maia.Key.Hangul_Banja;
            s_Keysyms[global::Xcb.KeySym.Hangul_PreHanja] = Maia.Key.Hangul_PreHanja;
            s_Keysyms[global::Xcb.KeySym.Hangul_PostHanja] = Maia.Key.Hangul_PostHanja;
            s_Keysyms[global::Xcb.KeySym.Hangul_SingleCandidate] = Maia.Key.Hangul_SingleCandidate;
            s_Keysyms[global::Xcb.KeySym.Hangul_MultipleCandidate] = Maia.Key.Hangul_MultipleCandidate;
            s_Keysyms[global::Xcb.KeySym.Hangul_PreviousCandidate] = Maia.Key.Hangul_PreviousCandidate;
            s_Keysyms[global::Xcb.KeySym.Hangul_Special] = Maia.Key.Hangul_Special;
            s_Keysyms[global::Xcb.KeySym.Hangul_switch] = Maia.Key.Hangul_switch;
            s_Keysyms[global::Xcb.KeySym.Hangul_Kiyeog] = Maia.Key.Hangul_Kiyeog;
            s_Keysyms[global::Xcb.KeySym.Hangul_SsangKiyeog] = Maia.Key.Hangul_SsangKiyeog;
            s_Keysyms[global::Xcb.KeySym.Hangul_KiyeogSios] = Maia.Key.Hangul_KiyeogSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_Nieun] = Maia.Key.Hangul_Nieun;
            s_Keysyms[global::Xcb.KeySym.Hangul_NieunJieuj] = Maia.Key.Hangul_NieunJieuj;
            s_Keysyms[global::Xcb.KeySym.Hangul_NieunHieuh] = Maia.Key.Hangul_NieunHieuh;
            s_Keysyms[global::Xcb.KeySym.Hangul_Dikeud] = Maia.Key.Hangul_Dikeud;
            s_Keysyms[global::Xcb.KeySym.Hangul_SsangDikeud] = Maia.Key.Hangul_SsangDikeud;
            s_Keysyms[global::Xcb.KeySym.Hangul_Rieul] = Maia.Key.Hangul_Rieul;
            s_Keysyms[global::Xcb.KeySym.Hangul_RieulKiyeog] = Maia.Key.Hangul_RieulKiyeog;
            s_Keysyms[global::Xcb.KeySym.Hangul_RieulMieum] = Maia.Key.Hangul_RieulMieum;
            s_Keysyms[global::Xcb.KeySym.Hangul_RieulPieub] = Maia.Key.Hangul_RieulPieub;
            s_Keysyms[global::Xcb.KeySym.Hangul_RieulSios] = Maia.Key.Hangul_RieulSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_RieulTieut] = Maia.Key.Hangul_RieulTieut;
            s_Keysyms[global::Xcb.KeySym.Hangul_RieulPhieuf] = Maia.Key.Hangul_RieulPhieuf;
            s_Keysyms[global::Xcb.KeySym.Hangul_RieulHieuh] = Maia.Key.Hangul_RieulHieuh;
            s_Keysyms[global::Xcb.KeySym.Hangul_Mieum] = Maia.Key.Hangul_Mieum;
            s_Keysyms[global::Xcb.KeySym.Hangul_Pieub] = Maia.Key.Hangul_Pieub;
            s_Keysyms[global::Xcb.KeySym.Hangul_SsangPieub] = Maia.Key.Hangul_SsangPieub;
            s_Keysyms[global::Xcb.KeySym.Hangul_PieubSios] = Maia.Key.Hangul_PieubSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_Sios] = Maia.Key.Hangul_Sios;
            s_Keysyms[global::Xcb.KeySym.Hangul_SsangSios] = Maia.Key.Hangul_SsangSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_Ieung] = Maia.Key.Hangul_Ieung;
            s_Keysyms[global::Xcb.KeySym.Hangul_Jieuj] = Maia.Key.Hangul_Jieuj;
            s_Keysyms[global::Xcb.KeySym.Hangul_SsangJieuj] = Maia.Key.Hangul_SsangJieuj;
            s_Keysyms[global::Xcb.KeySym.Hangul_Cieuc] = Maia.Key.Hangul_Cieuc;
            s_Keysyms[global::Xcb.KeySym.Hangul_Khieuq] = Maia.Key.Hangul_Khieuq;
            s_Keysyms[global::Xcb.KeySym.Hangul_Tieut] = Maia.Key.Hangul_Tieut;
            s_Keysyms[global::Xcb.KeySym.Hangul_Phieuf] = Maia.Key.Hangul_Phieuf;
            s_Keysyms[global::Xcb.KeySym.Hangul_Hieuh] = Maia.Key.Hangul_Hieuh;
            s_Keysyms[global::Xcb.KeySym.Hangul_A] = Maia.Key.Hangul_A;
            s_Keysyms[global::Xcb.KeySym.Hangul_AE] = Maia.Key.Hangul_AE;
            s_Keysyms[global::Xcb.KeySym.Hangul_YA] = Maia.Key.Hangul_YA;
            s_Keysyms[global::Xcb.KeySym.Hangul_YAE] = Maia.Key.Hangul_YAE;
            s_Keysyms[global::Xcb.KeySym.Hangul_EO] = Maia.Key.Hangul_EO;
            s_Keysyms[global::Xcb.KeySym.Hangul_E] = Maia.Key.Hangul_E;
            s_Keysyms[global::Xcb.KeySym.Hangul_YEO] = Maia.Key.Hangul_YEO;
            s_Keysyms[global::Xcb.KeySym.Hangul_YE] = Maia.Key.Hangul_YE;
            s_Keysyms[global::Xcb.KeySym.Hangul_O] = Maia.Key.Hangul_O;
            s_Keysyms[global::Xcb.KeySym.Hangul_WA] = Maia.Key.Hangul_WA;
            s_Keysyms[global::Xcb.KeySym.Hangul_WAE] = Maia.Key.Hangul_WAE;
            s_Keysyms[global::Xcb.KeySym.Hangul_OE] = Maia.Key.Hangul_OE;
            s_Keysyms[global::Xcb.KeySym.Hangul_YO] = Maia.Key.Hangul_YO;
            s_Keysyms[global::Xcb.KeySym.Hangul_U] = Maia.Key.Hangul_U;
            s_Keysyms[global::Xcb.KeySym.Hangul_WEO] = Maia.Key.Hangul_WEO;
            s_Keysyms[global::Xcb.KeySym.Hangul_WE] = Maia.Key.Hangul_WE;
            s_Keysyms[global::Xcb.KeySym.Hangul_WI] = Maia.Key.Hangul_WI;
            s_Keysyms[global::Xcb.KeySym.Hangul_YU] = Maia.Key.Hangul_YU;
            s_Keysyms[global::Xcb.KeySym.Hangul_EU] = Maia.Key.Hangul_EU;
            s_Keysyms[global::Xcb.KeySym.Hangul_YI] = Maia.Key.Hangul_YI;
            s_Keysyms[global::Xcb.KeySym.Hangul_I] = Maia.Key.Hangul_I;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Kiyeog] = Maia.Key.Hangul_J_Kiyeog;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_SsangKiyeog] = Maia.Key.Hangul_J_SsangKiyeog;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_KiyeogSios] = Maia.Key.Hangul_J_KiyeogSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Nieun] = Maia.Key.Hangul_J_Nieun;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_NieunJieuj] = Maia.Key.Hangul_J_NieunJieuj;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_NieunHieuh] = Maia.Key.Hangul_J_NieunHieuh;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Dikeud] = Maia.Key.Hangul_J_Dikeud;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Rieul] = Maia.Key.Hangul_J_Rieul;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_RieulKiyeog] = Maia.Key.Hangul_J_RieulKiyeog;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_RieulMieum] = Maia.Key.Hangul_J_RieulMieum;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_RieulPieub] = Maia.Key.Hangul_J_RieulPieub;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_RieulSios] = Maia.Key.Hangul_J_RieulSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_RieulTieut] = Maia.Key.Hangul_J_RieulTieut;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_RieulPhieuf] = Maia.Key.Hangul_J_RieulPhieuf;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_RieulHieuh] = Maia.Key.Hangul_J_RieulHieuh;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Mieum] = Maia.Key.Hangul_J_Mieum;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Pieub] = Maia.Key.Hangul_J_Pieub;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_PieubSios] = Maia.Key.Hangul_J_PieubSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Sios] = Maia.Key.Hangul_J_Sios;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_SsangSios] = Maia.Key.Hangul_J_SsangSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Ieung] = Maia.Key.Hangul_J_Ieung;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Jieuj] = Maia.Key.Hangul_J_Jieuj;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Cieuc] = Maia.Key.Hangul_J_Cieuc;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Khieuq] = Maia.Key.Hangul_J_Khieuq;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Tieut] = Maia.Key.Hangul_J_Tieut;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Phieuf] = Maia.Key.Hangul_J_Phieuf;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_Hieuh] = Maia.Key.Hangul_J_Hieuh;
            s_Keysyms[global::Xcb.KeySym.Hangul_RieulYeorinHieuh] = Maia.Key.Hangul_RieulYeorinHieuh;
            s_Keysyms[global::Xcb.KeySym.Hangul_SunkyeongeumMieum] = Maia.Key.Hangul_SunkyeongeumMieum;
            s_Keysyms[global::Xcb.KeySym.Hangul_SunkyeongeumPieub] = Maia.Key.Hangul_SunkyeongeumPieub;
            s_Keysyms[global::Xcb.KeySym.Hangul_PanSios] = Maia.Key.Hangul_PanSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_KkogjiDalrinIeung] = Maia.Key.Hangul_KkogjiDalrinIeung;
            s_Keysyms[global::Xcb.KeySym.Hangul_SunkyeongeumPhieuf] = Maia.Key.Hangul_SunkyeongeumPhieuf;
            s_Keysyms[global::Xcb.KeySym.Hangul_YeorinHieuh] = Maia.Key.Hangul_YeorinHieuh;
            s_Keysyms[global::Xcb.KeySym.Hangul_AraeA] = Maia.Key.Hangul_AraeA;
            s_Keysyms[global::Xcb.KeySym.Hangul_AraeAE] = Maia.Key.Hangul_AraeAE;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_PanSios] = Maia.Key.Hangul_J_PanSios;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_KkogjiDalrinIeung] = Maia.Key.Hangul_J_KkogjiDalrinIeung;
            s_Keysyms[global::Xcb.KeySym.Hangul_J_YeorinHieuh] = Maia.Key.Hangul_J_YeorinHieuh;
            s_Keysyms[global::Xcb.KeySym.Korean_Won] = Maia.Key.Korean_Won;
            s_Keysyms[global::Xcb.KeySym.Armenian_ligature_ew] = Maia.Key.Armenian_ligature_ew;
            s_Keysyms[global::Xcb.KeySym.Armenian_full_stop] = Maia.Key.Armenian_full_stop;
            s_Keysyms[global::Xcb.KeySym.Armenian_verjaket] = Maia.Key.Armenian_verjaket;
            s_Keysyms[global::Xcb.KeySym.Armenian_separation_mark] = Maia.Key.Armenian_separation_mark;
            s_Keysyms[global::Xcb.KeySym.Armenian_but] = Maia.Key.Armenian_but;
            s_Keysyms[global::Xcb.KeySym.Armenian_hyphen] = Maia.Key.Armenian_hyphen;
            s_Keysyms[global::Xcb.KeySym.Armenian_yentamna] = Maia.Key.Armenian_yentamna;
            s_Keysyms[global::Xcb.KeySym.Armenian_exclam] = Maia.Key.Armenian_exclam;
            s_Keysyms[global::Xcb.KeySym.Armenian_amanak] = Maia.Key.Armenian_amanak;
            s_Keysyms[global::Xcb.KeySym.Armenian_accent] = Maia.Key.Armenian_accent;
            s_Keysyms[global::Xcb.KeySym.Armenian_shesht] = Maia.Key.Armenian_shesht;
            s_Keysyms[global::Xcb.KeySym.Armenian_question] = Maia.Key.Armenian_question;
            s_Keysyms[global::Xcb.KeySym.Armenian_paruyk] = Maia.Key.Armenian_paruyk;
            s_Keysyms[global::Xcb.KeySym.Armenian_AYB] = Maia.Key.Armenian_AYB;
            s_Keysyms[global::Xcb.KeySym.Armenian_ayb] = Maia.Key.Armenian_ayb;
            s_Keysyms[global::Xcb.KeySym.Armenian_BEN] = Maia.Key.Armenian_BEN;
            s_Keysyms[global::Xcb.KeySym.Armenian_ben] = Maia.Key.Armenian_ben;
            s_Keysyms[global::Xcb.KeySym.Armenian_GIM] = Maia.Key.Armenian_GIM;
            s_Keysyms[global::Xcb.KeySym.Armenian_gim] = Maia.Key.Armenian_gim;
            s_Keysyms[global::Xcb.KeySym.Armenian_DA] = Maia.Key.Armenian_DA;
            s_Keysyms[global::Xcb.KeySym.Armenian_da] = Maia.Key.Armenian_da;
            s_Keysyms[global::Xcb.KeySym.Armenian_YECH] = Maia.Key.Armenian_YECH;
            s_Keysyms[global::Xcb.KeySym.Armenian_yech] = Maia.Key.Armenian_yech;
            s_Keysyms[global::Xcb.KeySym.Armenian_ZA] = Maia.Key.Armenian_ZA;
            s_Keysyms[global::Xcb.KeySym.Armenian_za] = Maia.Key.Armenian_za;
            s_Keysyms[global::Xcb.KeySym.Armenian_E] = Maia.Key.Armenian_E;
            s_Keysyms[global::Xcb.KeySym.Armenian_e] = Maia.Key.Armenian_e;
            s_Keysyms[global::Xcb.KeySym.Armenian_AT] = Maia.Key.Armenian_AT;
            s_Keysyms[global::Xcb.KeySym.Armenian_at] = Maia.Key.Armenian_at;
            s_Keysyms[global::Xcb.KeySym.Armenian_TO] = Maia.Key.Armenian_TO;
            s_Keysyms[global::Xcb.KeySym.Armenian_to] = Maia.Key.Armenian_to;
            s_Keysyms[global::Xcb.KeySym.Armenian_ZHE] = Maia.Key.Armenian_ZHE;
            s_Keysyms[global::Xcb.KeySym.Armenian_zhe] = Maia.Key.Armenian_zhe;
            s_Keysyms[global::Xcb.KeySym.Armenian_INI] = Maia.Key.Armenian_INI;
            s_Keysyms[global::Xcb.KeySym.Armenian_ini] = Maia.Key.Armenian_ini;
            s_Keysyms[global::Xcb.KeySym.Armenian_LYUN] = Maia.Key.Armenian_LYUN;
            s_Keysyms[global::Xcb.KeySym.Armenian_lyun] = Maia.Key.Armenian_lyun;
            s_Keysyms[global::Xcb.KeySym.Armenian_KHE] = Maia.Key.Armenian_KHE;
            s_Keysyms[global::Xcb.KeySym.Armenian_khe] = Maia.Key.Armenian_khe;
            s_Keysyms[global::Xcb.KeySym.Armenian_TSA] = Maia.Key.Armenian_TSA;
            s_Keysyms[global::Xcb.KeySym.Armenian_tsa] = Maia.Key.Armenian_tsa;
            s_Keysyms[global::Xcb.KeySym.Armenian_KEN] = Maia.Key.Armenian_KEN;
            s_Keysyms[global::Xcb.KeySym.Armenian_ken] = Maia.Key.Armenian_ken;
            s_Keysyms[global::Xcb.KeySym.Armenian_HO] = Maia.Key.Armenian_HO;
            s_Keysyms[global::Xcb.KeySym.Armenian_ho] = Maia.Key.Armenian_ho;
            s_Keysyms[global::Xcb.KeySym.Armenian_DZA] = Maia.Key.Armenian_DZA;
            s_Keysyms[global::Xcb.KeySym.Armenian_dza] = Maia.Key.Armenian_dza;
            s_Keysyms[global::Xcb.KeySym.Armenian_GHAT] = Maia.Key.Armenian_GHAT;
            s_Keysyms[global::Xcb.KeySym.Armenian_ghat] = Maia.Key.Armenian_ghat;
            s_Keysyms[global::Xcb.KeySym.Armenian_TCHE] = Maia.Key.Armenian_TCHE;
            s_Keysyms[global::Xcb.KeySym.Armenian_tche] = Maia.Key.Armenian_tche;
            s_Keysyms[global::Xcb.KeySym.Armenian_MEN] = Maia.Key.Armenian_MEN;
            s_Keysyms[global::Xcb.KeySym.Armenian_men] = Maia.Key.Armenian_men;
            s_Keysyms[global::Xcb.KeySym.Armenian_HI] = Maia.Key.Armenian_HI;
            s_Keysyms[global::Xcb.KeySym.Armenian_hi] = Maia.Key.Armenian_hi;
            s_Keysyms[global::Xcb.KeySym.Armenian_NU] = Maia.Key.Armenian_NU;
            s_Keysyms[global::Xcb.KeySym.Armenian_nu] = Maia.Key.Armenian_nu;
            s_Keysyms[global::Xcb.KeySym.Armenian_SHA] = Maia.Key.Armenian_SHA;
            s_Keysyms[global::Xcb.KeySym.Armenian_sha] = Maia.Key.Armenian_sha;
            s_Keysyms[global::Xcb.KeySym.Armenian_VO] = Maia.Key.Armenian_VO;
            s_Keysyms[global::Xcb.KeySym.Armenian_vo] = Maia.Key.Armenian_vo;
            s_Keysyms[global::Xcb.KeySym.Armenian_CHA] = Maia.Key.Armenian_CHA;
            s_Keysyms[global::Xcb.KeySym.Armenian_cha] = Maia.Key.Armenian_cha;
            s_Keysyms[global::Xcb.KeySym.Armenian_PE] = Maia.Key.Armenian_PE;
            s_Keysyms[global::Xcb.KeySym.Armenian_pe] = Maia.Key.Armenian_pe;
            s_Keysyms[global::Xcb.KeySym.Armenian_JE] = Maia.Key.Armenian_JE;
            s_Keysyms[global::Xcb.KeySym.Armenian_je] = Maia.Key.Armenian_je;
            s_Keysyms[global::Xcb.KeySym.Armenian_RA] = Maia.Key.Armenian_RA;
            s_Keysyms[global::Xcb.KeySym.Armenian_ra] = Maia.Key.Armenian_ra;
            s_Keysyms[global::Xcb.KeySym.Armenian_SE] = Maia.Key.Armenian_SE;
            s_Keysyms[global::Xcb.KeySym.Armenian_se] = Maia.Key.Armenian_se;
            s_Keysyms[global::Xcb.KeySym.Armenian_VEV] = Maia.Key.Armenian_VEV;
            s_Keysyms[global::Xcb.KeySym.Armenian_vev] = Maia.Key.Armenian_vev;
            s_Keysyms[global::Xcb.KeySym.Armenian_TYUN] = Maia.Key.Armenian_TYUN;
            s_Keysyms[global::Xcb.KeySym.Armenian_tyun] = Maia.Key.Armenian_tyun;
            s_Keysyms[global::Xcb.KeySym.Armenian_RE] = Maia.Key.Armenian_RE;
            s_Keysyms[global::Xcb.KeySym.Armenian_re] = Maia.Key.Armenian_re;
            s_Keysyms[global::Xcb.KeySym.Armenian_TSO] = Maia.Key.Armenian_TSO;
            s_Keysyms[global::Xcb.KeySym.Armenian_tso] = Maia.Key.Armenian_tso;
            s_Keysyms[global::Xcb.KeySym.Armenian_VYUN] = Maia.Key.Armenian_VYUN;
            s_Keysyms[global::Xcb.KeySym.Armenian_vyun] = Maia.Key.Armenian_vyun;
            s_Keysyms[global::Xcb.KeySym.Armenian_PYUR] = Maia.Key.Armenian_PYUR;
            s_Keysyms[global::Xcb.KeySym.Armenian_pyur] = Maia.Key.Armenian_pyur;
            s_Keysyms[global::Xcb.KeySym.Armenian_KE] = Maia.Key.Armenian_KE;
            s_Keysyms[global::Xcb.KeySym.Armenian_ke] = Maia.Key.Armenian_ke;
            s_Keysyms[global::Xcb.KeySym.Armenian_O] = Maia.Key.Armenian_O;
            s_Keysyms[global::Xcb.KeySym.Armenian_o] = Maia.Key.Armenian_o;
            s_Keysyms[global::Xcb.KeySym.Armenian_FE] = Maia.Key.Armenian_FE;
            s_Keysyms[global::Xcb.KeySym.Armenian_fe] = Maia.Key.Armenian_fe;
            s_Keysyms[global::Xcb.KeySym.Armenian_apostrophe] = Maia.Key.Armenian_apostrophe;
            s_Keysyms[global::Xcb.KeySym.Georgian_an] = Maia.Key.Georgian_an;
            s_Keysyms[global::Xcb.KeySym.Georgian_ban] = Maia.Key.Georgian_ban;
            s_Keysyms[global::Xcb.KeySym.Georgian_gan] = Maia.Key.Georgian_gan;
            s_Keysyms[global::Xcb.KeySym.Georgian_don] = Maia.Key.Georgian_don;
            s_Keysyms[global::Xcb.KeySym.Georgian_en] = Maia.Key.Georgian_en;
            s_Keysyms[global::Xcb.KeySym.Georgian_vin] = Maia.Key.Georgian_vin;
            s_Keysyms[global::Xcb.KeySym.Georgian_zen] = Maia.Key.Georgian_zen;
            s_Keysyms[global::Xcb.KeySym.Georgian_tan] = Maia.Key.Georgian_tan;
            s_Keysyms[global::Xcb.KeySym.Georgian_in] = Maia.Key.Georgian_in;
            s_Keysyms[global::Xcb.KeySym.Georgian_kan] = Maia.Key.Georgian_kan;
            s_Keysyms[global::Xcb.KeySym.Georgian_las] = Maia.Key.Georgian_las;
            s_Keysyms[global::Xcb.KeySym.Georgian_man] = Maia.Key.Georgian_man;
            s_Keysyms[global::Xcb.KeySym.Georgian_nar] = Maia.Key.Georgian_nar;
            s_Keysyms[global::Xcb.KeySym.Georgian_on] = Maia.Key.Georgian_on;
            s_Keysyms[global::Xcb.KeySym.Georgian_par] = Maia.Key.Georgian_par;
            s_Keysyms[global::Xcb.KeySym.Georgian_zhar] = Maia.Key.Georgian_zhar;
            s_Keysyms[global::Xcb.KeySym.Georgian_rae] = Maia.Key.Georgian_rae;
            s_Keysyms[global::Xcb.KeySym.Georgian_san] = Maia.Key.Georgian_san;
            s_Keysyms[global::Xcb.KeySym.Georgian_tar] = Maia.Key.Georgian_tar;
            s_Keysyms[global::Xcb.KeySym.Georgian_un] = Maia.Key.Georgian_un;
            s_Keysyms[global::Xcb.KeySym.Georgian_phar] = Maia.Key.Georgian_phar;
            s_Keysyms[global::Xcb.KeySym.Georgian_khar] = Maia.Key.Georgian_khar;
            s_Keysyms[global::Xcb.KeySym.Georgian_ghan] = Maia.Key.Georgian_ghan;
            s_Keysyms[global::Xcb.KeySym.Georgian_qar] = Maia.Key.Georgian_qar;
            s_Keysyms[global::Xcb.KeySym.Georgian_shin] = Maia.Key.Georgian_shin;
            s_Keysyms[global::Xcb.KeySym.Georgian_chin] = Maia.Key.Georgian_chin;
            s_Keysyms[global::Xcb.KeySym.Georgian_can] = Maia.Key.Georgian_can;
            s_Keysyms[global::Xcb.KeySym.Georgian_jil] = Maia.Key.Georgian_jil;
            s_Keysyms[global::Xcb.KeySym.Georgian_cil] = Maia.Key.Georgian_cil;
            s_Keysyms[global::Xcb.KeySym.Georgian_char] = Maia.Key.Georgian_char;
            s_Keysyms[global::Xcb.KeySym.Georgian_xan] = Maia.Key.Georgian_xan;
            s_Keysyms[global::Xcb.KeySym.Georgian_jhan] = Maia.Key.Georgian_jhan;
            s_Keysyms[global::Xcb.KeySym.Georgian_hae] = Maia.Key.Georgian_hae;
            s_Keysyms[global::Xcb.KeySym.Georgian_he] = Maia.Key.Georgian_he;
            s_Keysyms[global::Xcb.KeySym.Georgian_hie] = Maia.Key.Georgian_hie;
            s_Keysyms[global::Xcb.KeySym.Georgian_we] = Maia.Key.Georgian_we;
            s_Keysyms[global::Xcb.KeySym.Georgian_har] = Maia.Key.Georgian_har;
            s_Keysyms[global::Xcb.KeySym.Georgian_hoe] = Maia.Key.Georgian_hoe;
            s_Keysyms[global::Xcb.KeySym.Georgian_fi] = Maia.Key.Georgian_fi;
            s_Keysyms[global::Xcb.KeySym.Xabovedot] = Maia.Key.Xabovedot;
            s_Keysyms[global::Xcb.KeySym.Ibreve] = Maia.Key.Ibreve;
            s_Keysyms[global::Xcb.KeySym.Zstroke] = Maia.Key.Zstroke;
            s_Keysyms[global::Xcb.KeySym.Gcaron] = Maia.Key.Gcaron;
            s_Keysyms[global::Xcb.KeySym.Ocaron] = Maia.Key.Ocaron;
            s_Keysyms[global::Xcb.KeySym.Obarred] = Maia.Key.Obarred;
            s_Keysyms[global::Xcb.KeySym.xabovedot] = Maia.Key.xabovedot;
            s_Keysyms[global::Xcb.KeySym.ibreve] = Maia.Key.ibreve;
            s_Keysyms[global::Xcb.KeySym.zstroke] = Maia.Key.zstroke;
            s_Keysyms[global::Xcb.KeySym.gcaron] = Maia.Key.gcaron;
            s_Keysyms[global::Xcb.KeySym.ocaron] = Maia.Key.ocaron;
            s_Keysyms[global::Xcb.KeySym.obarred] = Maia.Key.obarred;
            s_Keysyms[global::Xcb.KeySym.SCHWA] = Maia.Key.SCHWA;
            s_Keysyms[global::Xcb.KeySym.schwa] = Maia.Key.schwa;
            s_Keysyms[global::Xcb.KeySym.Lbelowdot] = Maia.Key.Lbelowdot;
            s_Keysyms[global::Xcb.KeySym.lbelowdot] = Maia.Key.lbelowdot;
            s_Keysyms[global::Xcb.KeySym.Abelowdot] = Maia.Key.Abelowdot;
            s_Keysyms[global::Xcb.KeySym.abelowdot] = Maia.Key.abelowdot;
            s_Keysyms[global::Xcb.KeySym.Ahook] = Maia.Key.Ahook;
            s_Keysyms[global::Xcb.KeySym.ahook] = Maia.Key.ahook;
            s_Keysyms[global::Xcb.KeySym.Acircumflexacute] = Maia.Key.Acircumflexacute;
            s_Keysyms[global::Xcb.KeySym.acircumflexacute] = Maia.Key.acircumflexacute;
            s_Keysyms[global::Xcb.KeySym.Acircumflexgrave] = Maia.Key.Acircumflexgrave;
            s_Keysyms[global::Xcb.KeySym.acircumflexgrave] = Maia.Key.acircumflexgrave;
            s_Keysyms[global::Xcb.KeySym.Acircumflexhook] = Maia.Key.Acircumflexhook;
            s_Keysyms[global::Xcb.KeySym.acircumflexhook] = Maia.Key.acircumflexhook;
            s_Keysyms[global::Xcb.KeySym.Acircumflextilde] = Maia.Key.Acircumflextilde;
            s_Keysyms[global::Xcb.KeySym.acircumflextilde] = Maia.Key.acircumflextilde;
            s_Keysyms[global::Xcb.KeySym.Acircumflexbelowdot] = Maia.Key.Acircumflexbelowdot;
            s_Keysyms[global::Xcb.KeySym.acircumflexbelowdot] = Maia.Key.acircumflexbelowdot;
            s_Keysyms[global::Xcb.KeySym.Abreveacute] = Maia.Key.Abreveacute;
            s_Keysyms[global::Xcb.KeySym.abreveacute] = Maia.Key.abreveacute;
            s_Keysyms[global::Xcb.KeySym.Abrevegrave] = Maia.Key.Abrevegrave;
            s_Keysyms[global::Xcb.KeySym.abrevegrave] = Maia.Key.abrevegrave;
            s_Keysyms[global::Xcb.KeySym.Abrevehook] = Maia.Key.Abrevehook;
            s_Keysyms[global::Xcb.KeySym.abrevehook] = Maia.Key.abrevehook;
            s_Keysyms[global::Xcb.KeySym.Abrevetilde] = Maia.Key.Abrevetilde;
            s_Keysyms[global::Xcb.KeySym.abrevetilde] = Maia.Key.abrevetilde;
            s_Keysyms[global::Xcb.KeySym.Abrevebelowdot] = Maia.Key.Abrevebelowdot;
            s_Keysyms[global::Xcb.KeySym.abrevebelowdot] = Maia.Key.abrevebelowdot;
            s_Keysyms[global::Xcb.KeySym.Ebelowdot] = Maia.Key.Ebelowdot;
            s_Keysyms[global::Xcb.KeySym.ebelowdot] = Maia.Key.ebelowdot;
            s_Keysyms[global::Xcb.KeySym.Ehook] = Maia.Key.Ehook;
            s_Keysyms[global::Xcb.KeySym.ehook] = Maia.Key.ehook;
            s_Keysyms[global::Xcb.KeySym.Etilde] = Maia.Key.Etilde;
            s_Keysyms[global::Xcb.KeySym.etilde] = Maia.Key.etilde;
            s_Keysyms[global::Xcb.KeySym.Ecircumflexacute] = Maia.Key.Ecircumflexacute;
            s_Keysyms[global::Xcb.KeySym.ecircumflexacute] = Maia.Key.ecircumflexacute;
            s_Keysyms[global::Xcb.KeySym.Ecircumflexgrave] = Maia.Key.Ecircumflexgrave;
            s_Keysyms[global::Xcb.KeySym.ecircumflexgrave] = Maia.Key.ecircumflexgrave;
            s_Keysyms[global::Xcb.KeySym.Ecircumflexhook] = Maia.Key.Ecircumflexhook;
            s_Keysyms[global::Xcb.KeySym.ecircumflexhook] = Maia.Key.ecircumflexhook;
            s_Keysyms[global::Xcb.KeySym.Ecircumflextilde] = Maia.Key.Ecircumflextilde;
            s_Keysyms[global::Xcb.KeySym.ecircumflextilde] = Maia.Key.ecircumflextilde;
            s_Keysyms[global::Xcb.KeySym.Ecircumflexbelowdot] = Maia.Key.Ecircumflexbelowdot;
            s_Keysyms[global::Xcb.KeySym.ecircumflexbelowdot] = Maia.Key.ecircumflexbelowdot;
            s_Keysyms[global::Xcb.KeySym.Ihook] = Maia.Key.Ihook;
            s_Keysyms[global::Xcb.KeySym.ihook] = Maia.Key.ihook;
            s_Keysyms[global::Xcb.KeySym.Ibelowdot] = Maia.Key.Ibelowdot;
            s_Keysyms[global::Xcb.KeySym.ibelowdot] = Maia.Key.ibelowdot;
            s_Keysyms[global::Xcb.KeySym.Obelowdot] = Maia.Key.Obelowdot;
            s_Keysyms[global::Xcb.KeySym.obelowdot] = Maia.Key.obelowdot;
            s_Keysyms[global::Xcb.KeySym.Ohook] = Maia.Key.Ohook;
            s_Keysyms[global::Xcb.KeySym.ohook] = Maia.Key.ohook;
            s_Keysyms[global::Xcb.KeySym.Ocircumflexacute] = Maia.Key.Ocircumflexacute;
            s_Keysyms[global::Xcb.KeySym.ocircumflexacute] = Maia.Key.ocircumflexacute;
            s_Keysyms[global::Xcb.KeySym.Ocircumflexgrave] = Maia.Key.Ocircumflexgrave;
            s_Keysyms[global::Xcb.KeySym.ocircumflexgrave] = Maia.Key.ocircumflexgrave;
            s_Keysyms[global::Xcb.KeySym.Ocircumflexhook] = Maia.Key.Ocircumflexhook;
            s_Keysyms[global::Xcb.KeySym.ocircumflexhook] = Maia.Key.ocircumflexhook;
            s_Keysyms[global::Xcb.KeySym.Ocircumflextilde] = Maia.Key.Ocircumflextilde;
            s_Keysyms[global::Xcb.KeySym.ocircumflextilde] = Maia.Key.ocircumflextilde;
            s_Keysyms[global::Xcb.KeySym.Ocircumflexbelowdot] = Maia.Key.Ocircumflexbelowdot;
            s_Keysyms[global::Xcb.KeySym.ocircumflexbelowdot] = Maia.Key.ocircumflexbelowdot;
            s_Keysyms[global::Xcb.KeySym.Ohornacute] = Maia.Key.Ohornacute;
            s_Keysyms[global::Xcb.KeySym.ohornacute] = Maia.Key.ohornacute;
            s_Keysyms[global::Xcb.KeySym.Ohorngrave] = Maia.Key.Ohorngrave;
            s_Keysyms[global::Xcb.KeySym.ohorngrave] = Maia.Key.ohorngrave;
            s_Keysyms[global::Xcb.KeySym.Ohornhook] = Maia.Key.Ohornhook;
            s_Keysyms[global::Xcb.KeySym.ohornhook] = Maia.Key.ohornhook;
            s_Keysyms[global::Xcb.KeySym.Ohorntilde] = Maia.Key.Ohorntilde;
            s_Keysyms[global::Xcb.KeySym.ohorntilde] = Maia.Key.ohorntilde;
            s_Keysyms[global::Xcb.KeySym.Ohornbelowdot] = Maia.Key.Ohornbelowdot;
            s_Keysyms[global::Xcb.KeySym.ohornbelowdot] = Maia.Key.ohornbelowdot;
            s_Keysyms[global::Xcb.KeySym.Ubelowdot] = Maia.Key.Ubelowdot;
            s_Keysyms[global::Xcb.KeySym.ubelowdot] = Maia.Key.ubelowdot;
            s_Keysyms[global::Xcb.KeySym.Uhook] = Maia.Key.Uhook;
            s_Keysyms[global::Xcb.KeySym.uhook] = Maia.Key.uhook;
            s_Keysyms[global::Xcb.KeySym.Uhornacute] = Maia.Key.Uhornacute;
            s_Keysyms[global::Xcb.KeySym.uhornacute] = Maia.Key.uhornacute;
            s_Keysyms[global::Xcb.KeySym.Uhorngrave] = Maia.Key.Uhorngrave;
            s_Keysyms[global::Xcb.KeySym.uhorngrave] = Maia.Key.uhorngrave;
            s_Keysyms[global::Xcb.KeySym.Uhornhook] = Maia.Key.Uhornhook;
            s_Keysyms[global::Xcb.KeySym.uhornhook] = Maia.Key.uhornhook;
            s_Keysyms[global::Xcb.KeySym.Uhorntilde] = Maia.Key.Uhorntilde;
            s_Keysyms[global::Xcb.KeySym.uhorntilde] = Maia.Key.uhorntilde;
            s_Keysyms[global::Xcb.KeySym.Uhornbelowdot] = Maia.Key.Uhornbelowdot;
            s_Keysyms[global::Xcb.KeySym.uhornbelowdot] = Maia.Key.uhornbelowdot;
            s_Keysyms[global::Xcb.KeySym.Ybelowdot] = Maia.Key.Ybelowdot;
            s_Keysyms[global::Xcb.KeySym.ybelowdot] = Maia.Key.ybelowdot;
            s_Keysyms[global::Xcb.KeySym.Yhook] = Maia.Key.Yhook;
            s_Keysyms[global::Xcb.KeySym.yhook] = Maia.Key.yhook;
            s_Keysyms[global::Xcb.KeySym.Ytilde] = Maia.Key.Ytilde;
            s_Keysyms[global::Xcb.KeySym.ytilde] = Maia.Key.ytilde;
            s_Keysyms[global::Xcb.KeySym.Ohorn] = Maia.Key.Ohorn;
            s_Keysyms[global::Xcb.KeySym.ohorn] = Maia.Key.ohorn;
            s_Keysyms[global::Xcb.KeySym.Uhorn] = Maia.Key.Uhorn;
            s_Keysyms[global::Xcb.KeySym.uhorn] = Maia.Key.uhorn;
            s_Keysyms[global::Xcb.KeySym.EcuSign] = Maia.Key.EcuSign;
            s_Keysyms[global::Xcb.KeySym.ColonSign] = Maia.Key.ColonSign;
            s_Keysyms[global::Xcb.KeySym.CruzeiroSign] = Maia.Key.CruzeiroSign;
            s_Keysyms[global::Xcb.KeySym.FFrancSign] = Maia.Key.FFrancSign;
            s_Keysyms[global::Xcb.KeySym.LiraSign] = Maia.Key.LiraSign;
            s_Keysyms[global::Xcb.KeySym.MillSign] = Maia.Key.MillSign;
            s_Keysyms[global::Xcb.KeySym.NairaSign] = Maia.Key.NairaSign;
            s_Keysyms[global::Xcb.KeySym.PesetaSign] = Maia.Key.PesetaSign;
            s_Keysyms[global::Xcb.KeySym.RupeeSign] = Maia.Key.RupeeSign;
            s_Keysyms[global::Xcb.KeySym.WonSign] = Maia.Key.WonSign;
            s_Keysyms[global::Xcb.KeySym.NewSheqelSign] = Maia.Key.NewSheqelSign;
            s_Keysyms[global::Xcb.KeySym.DongSign] = Maia.Key.DongSign;
            s_Keysyms[global::Xcb.KeySym.EuroSign] = Maia.Key.EuroSign;
            s_Keysyms[global::Xcb.KeySym.zerosuperior] = Maia.Key.zerosuperior;
            s_Keysyms[global::Xcb.KeySym.foursuperior] = Maia.Key.foursuperior;
            s_Keysyms[global::Xcb.KeySym.fivesuperior] = Maia.Key.fivesuperior;
            s_Keysyms[global::Xcb.KeySym.sixsuperior] = Maia.Key.sixsuperior;
            s_Keysyms[global::Xcb.KeySym.sevensuperior] = Maia.Key.sevensuperior;
            s_Keysyms[global::Xcb.KeySym.eightsuperior] = Maia.Key.eightsuperior;
            s_Keysyms[global::Xcb.KeySym.ninesuperior] = Maia.Key.ninesuperior;
            s_Keysyms[global::Xcb.KeySym.zerosubscript] = Maia.Key.zerosubscript;
            s_Keysyms[global::Xcb.KeySym.onesubscript] = Maia.Key.onesubscript;
            s_Keysyms[global::Xcb.KeySym.twosubscript] = Maia.Key.twosubscript;
            s_Keysyms[global::Xcb.KeySym.threesubscript] = Maia.Key.threesubscript;
            s_Keysyms[global::Xcb.KeySym.foursubscript] = Maia.Key.foursubscript;
            s_Keysyms[global::Xcb.KeySym.fivesubscript] = Maia.Key.fivesubscript;
            s_Keysyms[global::Xcb.KeySym.sixsubscript] = Maia.Key.sixsubscript;
            s_Keysyms[global::Xcb.KeySym.sevensubscript] = Maia.Key.sevensubscript;
            s_Keysyms[global::Xcb.KeySym.eightsubscript] = Maia.Key.eightsubscript;
            s_Keysyms[global::Xcb.KeySym.ninesubscript] = Maia.Key.ninesubscript;
            s_Keysyms[global::Xcb.KeySym.partdifferential] = Maia.Key.partdifferential;
            s_Keysyms[global::Xcb.KeySym.emptyset] = Maia.Key.emptyset;
            s_Keysyms[global::Xcb.KeySym.elementof] = Maia.Key.elementof;
            s_Keysyms[global::Xcb.KeySym.notelementof] = Maia.Key.notelementof;
            s_Keysyms[global::Xcb.KeySym.containsas] = Maia.Key.containsas;
            s_Keysyms[global::Xcb.KeySym.squareroot] = Maia.Key.squareroot;
            s_Keysyms[global::Xcb.KeySym.cuberoot] = Maia.Key.cuberoot;
            s_Keysyms[global::Xcb.KeySym.fourthroot] = Maia.Key.fourthroot;
            s_Keysyms[global::Xcb.KeySym.dintegral] = Maia.Key.dintegral;
            s_Keysyms[global::Xcb.KeySym.tintegral] = Maia.Key.tintegral;
            s_Keysyms[global::Xcb.KeySym.because] = Maia.Key.because;
            s_Keysyms[global::Xcb.KeySym.approxeq] = Maia.Key.approxeq;
            s_Keysyms[global::Xcb.KeySym.notapproxeq] = Maia.Key.notapproxeq;
            s_Keysyms[global::Xcb.KeySym.notidentical] = Maia.Key.notidentical;
            s_Keysyms[global::Xcb.KeySym.stricteq] = Maia.Key.stricteq;
            s_Keysyms[global::Xcb.KeySym.braille_dot_1] = Maia.Key.braille_dot_1;
            s_Keysyms[global::Xcb.KeySym.braille_dot_2] = Maia.Key.braille_dot_2;
            s_Keysyms[global::Xcb.KeySym.braille_dot_3] = Maia.Key.braille_dot_3;
            s_Keysyms[global::Xcb.KeySym.braille_dot_4] = Maia.Key.braille_dot_4;
            s_Keysyms[global::Xcb.KeySym.braille_dot_5] = Maia.Key.braille_dot_5;
            s_Keysyms[global::Xcb.KeySym.braille_dot_6] = Maia.Key.braille_dot_6;
            s_Keysyms[global::Xcb.KeySym.braille_dot_7] = Maia.Key.braille_dot_7;
            s_Keysyms[global::Xcb.KeySym.braille_dot_8] = Maia.Key.braille_dot_8;
            s_Keysyms[global::Xcb.KeySym.braille_dot_9] = Maia.Key.braille_dot_9;
            s_Keysyms[global::Xcb.KeySym.braille_dot_10] = Maia.Key.braille_dot_10;
            s_Keysyms[global::Xcb.KeySym.braille_blank] = Maia.Key.braille_blank;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1] = Maia.Key.braille_dots_1;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2] = Maia.Key.braille_dots_2;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12] = Maia.Key.braille_dots_12;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3] = Maia.Key.braille_dots_3;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13] = Maia.Key.braille_dots_13;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23] = Maia.Key.braille_dots_23;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123] = Maia.Key.braille_dots_123;
            s_Keysyms[global::Xcb.KeySym.braille_dots_4] = Maia.Key.braille_dots_4;
            s_Keysyms[global::Xcb.KeySym.braille_dots_14] = Maia.Key.braille_dots_14;
            s_Keysyms[global::Xcb.KeySym.braille_dots_24] = Maia.Key.braille_dots_24;
            s_Keysyms[global::Xcb.KeySym.braille_dots_124] = Maia.Key.braille_dots_124;
            s_Keysyms[global::Xcb.KeySym.braille_dots_34] = Maia.Key.braille_dots_34;
            s_Keysyms[global::Xcb.KeySym.braille_dots_134] = Maia.Key.braille_dots_134;
            s_Keysyms[global::Xcb.KeySym.braille_dots_234] = Maia.Key.braille_dots_234;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1234] = Maia.Key.braille_dots_1234;
            s_Keysyms[global::Xcb.KeySym.braille_dots_5] = Maia.Key.braille_dots_5;
            s_Keysyms[global::Xcb.KeySym.braille_dots_15] = Maia.Key.braille_dots_15;
            s_Keysyms[global::Xcb.KeySym.braille_dots_25] = Maia.Key.braille_dots_25;
            s_Keysyms[global::Xcb.KeySym.braille_dots_125] = Maia.Key.braille_dots_125;
            s_Keysyms[global::Xcb.KeySym.braille_dots_35] = Maia.Key.braille_dots_35;
            s_Keysyms[global::Xcb.KeySym.braille_dots_135] = Maia.Key.braille_dots_135;
            s_Keysyms[global::Xcb.KeySym.braille_dots_235] = Maia.Key.braille_dots_235;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1235] = Maia.Key.braille_dots_1235;
            s_Keysyms[global::Xcb.KeySym.braille_dots_45] = Maia.Key.braille_dots_45;
            s_Keysyms[global::Xcb.KeySym.braille_dots_145] = Maia.Key.braille_dots_145;
            s_Keysyms[global::Xcb.KeySym.braille_dots_245] = Maia.Key.braille_dots_245;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1245] = Maia.Key.braille_dots_1245;
            s_Keysyms[global::Xcb.KeySym.braille_dots_345] = Maia.Key.braille_dots_345;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1345] = Maia.Key.braille_dots_1345;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2345] = Maia.Key.braille_dots_2345;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12345] = Maia.Key.braille_dots_12345;
            s_Keysyms[global::Xcb.KeySym.braille_dots_6] = Maia.Key.braille_dots_6;
            s_Keysyms[global::Xcb.KeySym.braille_dots_16] = Maia.Key.braille_dots_16;
            s_Keysyms[global::Xcb.KeySym.braille_dots_26] = Maia.Key.braille_dots_26;
            s_Keysyms[global::Xcb.KeySym.braille_dots_126] = Maia.Key.braille_dots_126;
            s_Keysyms[global::Xcb.KeySym.braille_dots_36] = Maia.Key.braille_dots_36;
            s_Keysyms[global::Xcb.KeySym.braille_dots_136] = Maia.Key.braille_dots_136;
            s_Keysyms[global::Xcb.KeySym.braille_dots_236] = Maia.Key.braille_dots_236;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1236] = Maia.Key.braille_dots_1236;
            s_Keysyms[global::Xcb.KeySym.braille_dots_46] = Maia.Key.braille_dots_46;
            s_Keysyms[global::Xcb.KeySym.braille_dots_146] = Maia.Key.braille_dots_146;
            s_Keysyms[global::Xcb.KeySym.braille_dots_246] = Maia.Key.braille_dots_246;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1246] = Maia.Key.braille_dots_1246;
            s_Keysyms[global::Xcb.KeySym.braille_dots_346] = Maia.Key.braille_dots_346;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1346] = Maia.Key.braille_dots_1346;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2346] = Maia.Key.braille_dots_2346;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12346] = Maia.Key.braille_dots_12346;
            s_Keysyms[global::Xcb.KeySym.braille_dots_56] = Maia.Key.braille_dots_56;
            s_Keysyms[global::Xcb.KeySym.braille_dots_156] = Maia.Key.braille_dots_156;
            s_Keysyms[global::Xcb.KeySym.braille_dots_256] = Maia.Key.braille_dots_256;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1256] = Maia.Key.braille_dots_1256;
            s_Keysyms[global::Xcb.KeySym.braille_dots_356] = Maia.Key.braille_dots_356;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1356] = Maia.Key.braille_dots_1356;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2356] = Maia.Key.braille_dots_2356;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12356] = Maia.Key.braille_dots_12356;
            s_Keysyms[global::Xcb.KeySym.braille_dots_456] = Maia.Key.braille_dots_456;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1456] = Maia.Key.braille_dots_1456;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2456] = Maia.Key.braille_dots_2456;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12456] = Maia.Key.braille_dots_12456;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3456] = Maia.Key.braille_dots_3456;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13456] = Maia.Key.braille_dots_13456;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23456] = Maia.Key.braille_dots_23456;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123456] = Maia.Key.braille_dots_123456;
            s_Keysyms[global::Xcb.KeySym.braille_dots_7] = Maia.Key.braille_dots_7;
            s_Keysyms[global::Xcb.KeySym.braille_dots_17] = Maia.Key.braille_dots_17;
            s_Keysyms[global::Xcb.KeySym.braille_dots_27] = Maia.Key.braille_dots_27;
            s_Keysyms[global::Xcb.KeySym.braille_dots_127] = Maia.Key.braille_dots_127;
            s_Keysyms[global::Xcb.KeySym.braille_dots_37] = Maia.Key.braille_dots_37;
            s_Keysyms[global::Xcb.KeySym.braille_dots_137] = Maia.Key.braille_dots_137;
            s_Keysyms[global::Xcb.KeySym.braille_dots_237] = Maia.Key.braille_dots_237;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1237] = Maia.Key.braille_dots_1237;
            s_Keysyms[global::Xcb.KeySym.braille_dots_47] = Maia.Key.braille_dots_47;
            s_Keysyms[global::Xcb.KeySym.braille_dots_147] = Maia.Key.braille_dots_147;
            s_Keysyms[global::Xcb.KeySym.braille_dots_247] = Maia.Key.braille_dots_247;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1247] = Maia.Key.braille_dots_1247;
            s_Keysyms[global::Xcb.KeySym.braille_dots_347] = Maia.Key.braille_dots_347;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1347] = Maia.Key.braille_dots_1347;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2347] = Maia.Key.braille_dots_2347;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12347] = Maia.Key.braille_dots_12347;
            s_Keysyms[global::Xcb.KeySym.braille_dots_57] = Maia.Key.braille_dots_57;
            s_Keysyms[global::Xcb.KeySym.braille_dots_157] = Maia.Key.braille_dots_157;
            s_Keysyms[global::Xcb.KeySym.braille_dots_257] = Maia.Key.braille_dots_257;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1257] = Maia.Key.braille_dots_1257;
            s_Keysyms[global::Xcb.KeySym.braille_dots_357] = Maia.Key.braille_dots_357;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1357] = Maia.Key.braille_dots_1357;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2357] = Maia.Key.braille_dots_2357;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12357] = Maia.Key.braille_dots_12357;
            s_Keysyms[global::Xcb.KeySym.braille_dots_457] = Maia.Key.braille_dots_457;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1457] = Maia.Key.braille_dots_1457;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2457] = Maia.Key.braille_dots_2457;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12457] = Maia.Key.braille_dots_12457;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3457] = Maia.Key.braille_dots_3457;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13457] = Maia.Key.braille_dots_13457;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23457] = Maia.Key.braille_dots_23457;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123457] = Maia.Key.braille_dots_123457;
            s_Keysyms[global::Xcb.KeySym.braille_dots_67] = Maia.Key.braille_dots_67;
            s_Keysyms[global::Xcb.KeySym.braille_dots_167] = Maia.Key.braille_dots_167;
            s_Keysyms[global::Xcb.KeySym.braille_dots_267] = Maia.Key.braille_dots_267;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1267] = Maia.Key.braille_dots_1267;
            s_Keysyms[global::Xcb.KeySym.braille_dots_367] = Maia.Key.braille_dots_367;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1367] = Maia.Key.braille_dots_1367;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2367] = Maia.Key.braille_dots_2367;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12367] = Maia.Key.braille_dots_12367;
            s_Keysyms[global::Xcb.KeySym.braille_dots_467] = Maia.Key.braille_dots_467;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1467] = Maia.Key.braille_dots_1467;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2467] = Maia.Key.braille_dots_2467;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12467] = Maia.Key.braille_dots_12467;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3467] = Maia.Key.braille_dots_3467;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13467] = Maia.Key.braille_dots_13467;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23467] = Maia.Key.braille_dots_23467;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123467] = Maia.Key.braille_dots_123467;
            s_Keysyms[global::Xcb.KeySym.braille_dots_567] = Maia.Key.braille_dots_567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1567] = Maia.Key.braille_dots_1567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2567] = Maia.Key.braille_dots_2567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12567] = Maia.Key.braille_dots_12567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3567] = Maia.Key.braille_dots_3567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13567] = Maia.Key.braille_dots_13567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23567] = Maia.Key.braille_dots_23567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123567] = Maia.Key.braille_dots_123567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_4567] = Maia.Key.braille_dots_4567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_14567] = Maia.Key.braille_dots_14567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_24567] = Maia.Key.braille_dots_24567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_124567] = Maia.Key.braille_dots_124567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_34567] = Maia.Key.braille_dots_34567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_134567] = Maia.Key.braille_dots_134567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_234567] = Maia.Key.braille_dots_234567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1234567] = Maia.Key.braille_dots_1234567;
            s_Keysyms[global::Xcb.KeySym.braille_dots_8] = Maia.Key.braille_dots_8;
            s_Keysyms[global::Xcb.KeySym.braille_dots_18] = Maia.Key.braille_dots_18;
            s_Keysyms[global::Xcb.KeySym.braille_dots_28] = Maia.Key.braille_dots_28;
            s_Keysyms[global::Xcb.KeySym.braille_dots_128] = Maia.Key.braille_dots_128;
            s_Keysyms[global::Xcb.KeySym.braille_dots_38] = Maia.Key.braille_dots_38;
            s_Keysyms[global::Xcb.KeySym.braille_dots_138] = Maia.Key.braille_dots_138;
            s_Keysyms[global::Xcb.KeySym.braille_dots_238] = Maia.Key.braille_dots_238;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1238] = Maia.Key.braille_dots_1238;
            s_Keysyms[global::Xcb.KeySym.braille_dots_48] = Maia.Key.braille_dots_48;
            s_Keysyms[global::Xcb.KeySym.braille_dots_148] = Maia.Key.braille_dots_148;
            s_Keysyms[global::Xcb.KeySym.braille_dots_248] = Maia.Key.braille_dots_248;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1248] = Maia.Key.braille_dots_1248;
            s_Keysyms[global::Xcb.KeySym.braille_dots_348] = Maia.Key.braille_dots_348;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1348] = Maia.Key.braille_dots_1348;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2348] = Maia.Key.braille_dots_2348;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12348] = Maia.Key.braille_dots_12348;
            s_Keysyms[global::Xcb.KeySym.braille_dots_58] = Maia.Key.braille_dots_58;
            s_Keysyms[global::Xcb.KeySym.braille_dots_158] = Maia.Key.braille_dots_158;
            s_Keysyms[global::Xcb.KeySym.braille_dots_258] = Maia.Key.braille_dots_258;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1258] = Maia.Key.braille_dots_1258;
            s_Keysyms[global::Xcb.KeySym.braille_dots_358] = Maia.Key.braille_dots_358;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1358] = Maia.Key.braille_dots_1358;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2358] = Maia.Key.braille_dots_2358;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12358] = Maia.Key.braille_dots_12358;
            s_Keysyms[global::Xcb.KeySym.braille_dots_458] = Maia.Key.braille_dots_458;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1458] = Maia.Key.braille_dots_1458;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2458] = Maia.Key.braille_dots_2458;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12458] = Maia.Key.braille_dots_12458;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3458] = Maia.Key.braille_dots_3458;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13458] = Maia.Key.braille_dots_13458;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23458] = Maia.Key.braille_dots_23458;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123458] = Maia.Key.braille_dots_123458;
            s_Keysyms[global::Xcb.KeySym.braille_dots_68] = Maia.Key.braille_dots_68;
            s_Keysyms[global::Xcb.KeySym.braille_dots_168] = Maia.Key.braille_dots_168;
            s_Keysyms[global::Xcb.KeySym.braille_dots_268] = Maia.Key.braille_dots_268;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1268] = Maia.Key.braille_dots_1268;
            s_Keysyms[global::Xcb.KeySym.braille_dots_368] = Maia.Key.braille_dots_368;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1368] = Maia.Key.braille_dots_1368;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2368] = Maia.Key.braille_dots_2368;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12368] = Maia.Key.braille_dots_12368;
            s_Keysyms[global::Xcb.KeySym.braille_dots_468] = Maia.Key.braille_dots_468;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1468] = Maia.Key.braille_dots_1468;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2468] = Maia.Key.braille_dots_2468;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12468] = Maia.Key.braille_dots_12468;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3468] = Maia.Key.braille_dots_3468;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13468] = Maia.Key.braille_dots_13468;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23468] = Maia.Key.braille_dots_23468;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123468] = Maia.Key.braille_dots_123468;
            s_Keysyms[global::Xcb.KeySym.braille_dots_568] = Maia.Key.braille_dots_568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1568] = Maia.Key.braille_dots_1568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2568] = Maia.Key.braille_dots_2568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12568] = Maia.Key.braille_dots_12568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3568] = Maia.Key.braille_dots_3568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13568] = Maia.Key.braille_dots_13568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23568] = Maia.Key.braille_dots_23568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123568] = Maia.Key.braille_dots_123568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_4568] = Maia.Key.braille_dots_4568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_14568] = Maia.Key.braille_dots_14568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_24568] = Maia.Key.braille_dots_24568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_124568] = Maia.Key.braille_dots_124568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_34568] = Maia.Key.braille_dots_34568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_134568] = Maia.Key.braille_dots_134568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_234568] = Maia.Key.braille_dots_234568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1234568] = Maia.Key.braille_dots_1234568;
            s_Keysyms[global::Xcb.KeySym.braille_dots_78] = Maia.Key.braille_dots_78;
            s_Keysyms[global::Xcb.KeySym.braille_dots_178] = Maia.Key.braille_dots_178;
            s_Keysyms[global::Xcb.KeySym.braille_dots_278] = Maia.Key.braille_dots_278;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1278] = Maia.Key.braille_dots_1278;
            s_Keysyms[global::Xcb.KeySym.braille_dots_378] = Maia.Key.braille_dots_378;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1378] = Maia.Key.braille_dots_1378;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2378] = Maia.Key.braille_dots_2378;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12378] = Maia.Key.braille_dots_12378;
            s_Keysyms[global::Xcb.KeySym.braille_dots_478] = Maia.Key.braille_dots_478;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1478] = Maia.Key.braille_dots_1478;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2478] = Maia.Key.braille_dots_2478;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12478] = Maia.Key.braille_dots_12478;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3478] = Maia.Key.braille_dots_3478;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13478] = Maia.Key.braille_dots_13478;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23478] = Maia.Key.braille_dots_23478;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123478] = Maia.Key.braille_dots_123478;
            s_Keysyms[global::Xcb.KeySym.braille_dots_578] = Maia.Key.braille_dots_578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1578] = Maia.Key.braille_dots_1578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2578] = Maia.Key.braille_dots_2578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12578] = Maia.Key.braille_dots_12578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3578] = Maia.Key.braille_dots_3578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13578] = Maia.Key.braille_dots_13578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23578] = Maia.Key.braille_dots_23578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123578] = Maia.Key.braille_dots_123578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_4578] = Maia.Key.braille_dots_4578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_14578] = Maia.Key.braille_dots_14578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_24578] = Maia.Key.braille_dots_24578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_124578] = Maia.Key.braille_dots_124578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_34578] = Maia.Key.braille_dots_34578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_134578] = Maia.Key.braille_dots_134578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_234578] = Maia.Key.braille_dots_234578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1234578] = Maia.Key.braille_dots_1234578;
            s_Keysyms[global::Xcb.KeySym.braille_dots_678] = Maia.Key.braille_dots_678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1678] = Maia.Key.braille_dots_1678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2678] = Maia.Key.braille_dots_2678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12678] = Maia.Key.braille_dots_12678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_3678] = Maia.Key.braille_dots_3678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_13678] = Maia.Key.braille_dots_13678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_23678] = Maia.Key.braille_dots_23678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_123678] = Maia.Key.braille_dots_123678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_4678] = Maia.Key.braille_dots_4678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_14678] = Maia.Key.braille_dots_14678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_24678] = Maia.Key.braille_dots_24678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_124678] = Maia.Key.braille_dots_124678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_34678] = Maia.Key.braille_dots_34678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_134678] = Maia.Key.braille_dots_134678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_234678] = Maia.Key.braille_dots_234678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1234678] = Maia.Key.braille_dots_1234678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_5678] = Maia.Key.braille_dots_5678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_15678] = Maia.Key.braille_dots_15678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_25678] = Maia.Key.braille_dots_25678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_125678] = Maia.Key.braille_dots_125678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_35678] = Maia.Key.braille_dots_35678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_135678] = Maia.Key.braille_dots_135678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_235678] = Maia.Key.braille_dots_235678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1235678] = Maia.Key.braille_dots_1235678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_45678] = Maia.Key.braille_dots_45678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_145678] = Maia.Key.braille_dots_145678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_245678] = Maia.Key.braille_dots_245678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1245678] = Maia.Key.braille_dots_1245678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_345678] = Maia.Key.braille_dots_345678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_1345678] = Maia.Key.braille_dots_1345678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_2345678] = Maia.Key.braille_dots_2345678;
            s_Keysyms[global::Xcb.KeySym.braille_dots_12345678] = Maia.Key.braille_dots_12345678;
        }

        return (Maia.Key)s_Keysyms[inKey];
    }
}
