
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';               //Formato A4
import 'package:pdf/widgets.dart' as pw;     //permite montar o PDF
import 'package:printing/printing.dart';     //permite compartilhar o PDF

class OrcamentoPdf {
  static String moeda(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static Future<void> gerar({
    required Map<String, dynamic> orcamento,
    required String garantia,
    required String numero,
  }) async {
    final pdf = pw.Document();

    final itens = (orcamento['itens'] as List? ?? [])
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    final produtos = itens
        .where((item) =>
    item['tipo'].toString().toLowerCase() == 'produto')
        .toList();

    final servicos = itens
        .where((item) =>
    item['tipo'].toString().toLowerCase() == 'serviço' ||
        item['tipo'].toString().toLowerCase() == 'servico')
        .toList();

    // Inclui itens cujo tipo não corresponde aos nomes esperados.
    final outros = itens
        .where((item) =>
    !produtos.contains(item) && !servicos.contains(item))
        .toList();

    produtos.addAll(outros);

    double subtotal(List<Map<String, dynamic>> lista) {
      double total = 0;
      for (final item in lista) {
        final preco = double.tryParse('${item['preco']}') ?? 0;
        final quantidade =
            int.tryParse('${item['quantidade']}') ?? 0;
        total += preco * quantidade;
      }
      return total;
    }

    final totalProdutos = subtotal(produtos);
    final totalServicos = subtotal(servicos);
    final totalGeral = totalProdutos + totalServicos;

    final dataOriginal = '${orcamento['data'] ?? ''}';
    final data = dataOriginal.length >= 10
        ? '${dataOriginal.substring(8, 10)}/'
        '${dataOriginal.substring(5, 7)}/'
        '${dataOriginal.substring(0, 4)}'
        : dataOriginal;

    pw.Widget texto(
        String valor, {
          bool negrito = false,
          double tamanho = 9,
        }) {
      return pw.Text(
        valor,
        style: pw.TextStyle(
          fontSize: tamanho,
          fontWeight:
          negrito ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      );
    }

    pw.Widget tabelaItens(
        String titulo,
        List<Map<String, dynamic>> lista,
        ) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(8),
            color: PdfColors.blueGrey800,
            child: pw.Text(
              titulo,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.TableHelper.fromTextArray(
            headers: [
              'Descrição',
              'Qtd.',
              'Unid.',
              'Valor unitário',
              'Valor total',
            ],
            data: lista.map((item) {
              final nome = '${item['nome'] ?? 'Item'}';
              final quantidade =
                  int.tryParse('${item['quantidade']}') ?? 0;
              final preco =
                  double.tryParse('${item['preco']}') ?? 0;
              return [
                nome,
                '$quantidade',
                'un.',
                moeda(preco),
                moeda(preco * quantidade),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey600,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding: const pw.EdgeInsets.all(6),
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(3.5),
              1: const pw.FlexColumnWidth(0.7),
              2: const pw.FlexColumnWidth(0.7),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
          ),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.all(8),
            child: texto(
              'Total: ${moeda(subtotal(lista))}',
              negrito: true,
            ),
          ),
          pw.SizedBox(height: 12),
        ],
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey900,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AQUIOS',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'ORÇAMENTO DE PRODUTOS E SERVIÇOS',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          texto('DADOS DO CLIENTE', negrito: true, tamanho: 12),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                texto('Cliente: ${orcamento['cliente'] ?? ''}'),
                pw.SizedBox(height: 5),
                texto('Data de emissão: $data'),
                pw.SizedBox(height: 5),
                texto('Orçamento Nº: $numero'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          if (servicos.isNotEmpty)
            tabelaItens('SERVIÇOS', servicos),
          if (produtos.isNotEmpty)
            tabelaItens('PRODUTOS', produtos),
          pw.SizedBox(height: 4),
          texto('RESUMO FINANCEIRO', negrito: true, tamanho: 12),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Descrição', 'Valor'],
            data: [
              ['Total de serviços', moeda(totalServicos)],
              ['Total de produtos', moeda(totalProdutos)],
              ['Subtotal', moeda(totalGeral)],
            ],
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.blueGrey600,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.all(7),
            border: pw.TableBorder.all(
              color: PdfColors.grey300,
              width: 0.5,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            color: PdfColors.blueGrey900,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL DO ORÇAMENTO',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Text(
                  moeda(totalGeral),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 22),
          texto('OBSERVAÇÕES E CONDIÇÕES',
              negrito: true, tamanho: 12),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                texto(
                  'Formas de pagamento: Cartão de Crédito, '
                      'Cartão de Débito, Dinheiro e Pix',
                ),
                pw.SizedBox(height: 6),
                texto('Condições: 3x sem juros; 10x com juros'),
                pw.SizedBox(height: 6),
                texto('Garantia: $garantia'),
                pw.SizedBox(height: 6),
                texto(
                  'Informação técnica: Toda a instalação será '
                      'realizada em Sistema ZigBee.',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Center(
            child: texto(
              'Obrigado pela preferência!',
              negrito: true,
              tamanho: 11,
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Orcamento_$numero.pdf',
    );
  }
}
