{% extends parameters.print ? "printbase" : "base" %}
{% block extrastyles %}
  .pagebreak
	{
		page-break-after: always;
	}
	.workorder
	{
		margin: 10px;
		font: normal 10pt 'Helvetica Neue',Helvetica,Arial,sans-serif;

	}
	.header h1	{
		text-align: center;
		font-size: 12pt;
	}
	.header h3, .header p	{
		font-size: 10pt;
		margin:0;
		text-align: center;
	}
    .header h1 strong {
		border: 3px solid black;
		display: block;
		margin: 0 auto;
		font-size: 24pt;
		width: 2em;
		padding: 10px
    }
	.header img {
		display: block;
		margin: 8px auto 4px;
	}
	.detail h2 {
		margin: 0px;
		padding: 0px;
		font-size: 11pt;
	}
	.detail { margin-bottom: 1em; }

	table.lines, table.totals { 
	    width: 100%; 
	    border-spacing:0;
        border-collapse:collapse;
	}
    table.lines td, table.totals td {
        padding: 4px 0;
    }
	table.lines th {
		font-size: 10pt;
		border-bottom: 1px solid #000;
		margin-bottom: 3px;
		text-align: left;
	}
	table.lines td.notes { margin-left: 15px; }
	
	table td.amount { 
	    width: 10%; 
	    text-align: left;
	}
	
	table.totals { 
	    text-align: right; 
	    border-top: 1px solid #000;
	}
	table.totals tr td:first-child { padding-right: 10px; }
	table tr.total td { font-weight: bold; font: normal 10pt 'Helvetica Neue',Helvetica,Arial,sans-serif; }

	.notes {
		overflow: hidden;
		margin: 0 0 1em;
	}
	.notes h1 { margin: 1em 0 0; }

	img.barcode 
	{
		display: block;
		margin: 2em auto; 
	}
{% endblock extrastyles %}

{% block content %}
	{% for Workorder in Workorders %}
	<div class="workorder {% if not loop.last %} pagebreak{% endif %}">
		<div class="header">
			{% if Workorder.Shop.ReceiptSetup.logo|strlen > 0 %}
			<img src="{{Workorder.Shop.ReceiptSetup.logo}}" width="{{Workorder.Shop.ReceiptSetup.logoWidth}}" height="{{Workorder.Shop.ReceiptSetup.logoHeight}}" class="logo">
			{% endif %}
			<h3>{{ Workorder.Shop.name }}</h3>
			{% if Workorder.Shop.ReceiptSetup.header|strlen > 0 %}
				{{Workorder.Shop.ReceiptSetup.header|nl2br|raw}}
			{% else %}
				<p>{{ _self.address(Workorder.Shop.Contact) }}</p>
				{% for ContactPhone in Workorder.Shop.Contact.Phones.ContactPhone %}{% if loop.first %}
				<p>{{ContactPhone.number}}</p>
				{% endif %}{% endfor %}
			{% endif %}

			<h1>WORK ORDER<strong>#{{Workorder.workorderID}}</strong></h1>
		</div>
		<div class="detail">
			<h2>Customer: {{ Workorder.Customer.lastName}}, {{ Workorder.Customer.firstName}}</h2>
			<h2>Started: {{Workorder.timeIn|correcttimezone|date ("m/d/y h:i a")}}</h2>
			<h2>Due on: {{Workorder.etaOut|correcttimezone|date ("m/d/y h:i a")}}</h2>
		</div>

		<table class="lines">
			<tr>
				<th>Item/Labor</th>
				<th>Notes</th>
				{% if parameters.type == 'invoice' %}<th>Charge</th>{% endif %}
			</tr>
			{% for WorkorderItem in Workorder.WorkorderItems.WorkorderItem %}
			<tr>
				{% if WorkorderLine.itemID != 0 %}
				<td class="description"></td>
				{% else %}
				<td class="description">
				    {% if WorkorderLine.unitQuantity > 0 %}
				    {{ WorkorderLine.unitQuantity }} &times; 
				    {% endif %}
				    {{ WorkorderItem.Item.description }}
				    
				    {% if WorkorderItem.Discount %}
				    <br>{{WorkorderItem.Discount.name}} ({{WorkorderItem.SaleLine.calcLineDiscount|money}})
				    {% endif %}
				</td>
				{% endif %}
				<td class="notes">{{ WorkorderItem.note }}</td>
				{% if parameters.type == 'invoice' %}
				{% if WorkorderItem.warranty == 'true' %}
				<td class="amount"> $0.00
				{% endif %}
				{% if WorkorderItem.warranty == 'false' %}
				<td class="amount">	
				    {{ WorkorderItem.SaleLine.calcSubtotal | money}}
				<td>
				{% endif %}
				{% endif %}
			</tr>
			{% endfor %}
			{% for WorkorderLine in Workorder.WorkorderLines.WorkorderLine %} <!--this loop is necessary for showing labor charges -->
			<tr>
				{% if WorkorderLine.itemID != 0 %}
				<td class="description">
				    {{ WorkorderLine.Item.description }}
				    
				    {% if WorkorderLine.Discount %}
				    <br>Discount: {{WorkorderLine.Discount.name}} ({{ WorkorderLine.SaleLine.calcLineDiscount | money}})
				    {% endif %}
				</td>
				<td class="notes">{{ WorkorderLine.note }}</td>
				{% else %}
				<td class="notes" colspan="2">
				    {{ WorkorderLine.note }}
				    
				    {% if WorkorderLine.Discount %}
				    <br>{{WorkorderLine.Discount.name}} ({{WorkorderLine.SaleLine.calcLineDiscount|money}})
				    {% endif %}
				</td>
				{% endif %}
				{% if parameters.type == 'invoice' %}
				<td class="amount">{{WorkorderLine.SaleLine.calcSubtotal | money}}</td>
				{% endif %}
			</tr>
			{% endfor %}
		</table>

        <table class="totals">
        	<tbody>
                <tr><td>Labor</td><td class="amount">{{Workorder.MetaData.labor|money}}</td></tr>
                <tr><td>Parts</td><td class="amount">{{Workorder.MetaData.parts|money}}</td></tr>
          		{% if Workorder.MetaData.discount > 0 %}<tr><td>Discounts</td><td class="amount">-{{Workorder.MetaData.discount|money}}</td></tr>{% endif %}
                <tr><td>Tax</td><td class="amount">{{Workorder.MetaData.tax|money}}</td></tr>
        		<tr class="total"><td>Total</td><td class="amount">{{Workorder.MetaData.total|money}}</td></tr>
        	</tbody>
        </table>
		
		{% if Workorder.note|length > 1 %}
		<div class="notes">
			<h3>Notes:</h3>
			{{ Workorder.note }}
		</div>
		{% endif %}
		
		<img height="50" width="250" class="barcode" src="/barcode.php?type=receipt&number={{Workorder.systemSku}}">
	</div>
	{% endfor %}

{% macro address(Contact,delimiter) %}
	{% if delimiter|strlen == 0 %}{% set delimiter = '<br>' %}{% endif %}

	{% autoescape false %}
	{% for Address in Contact.Addresses.ContactAddress %}
		{% if loop.first and Address.address1 %}
			{{Address.address1}}{{delimiter}}
			{% if Address.address2|strlen > 0 %} {{Address.address2}}{{delimiter}}{% endif %}
			{{Address.city}}, {{Address.state}} {{Address.zip}} {{Address.country}}
		{% endif %}
	{% endfor %}
	{% endautoescape %}
{% endmacro %}

{% endblock content %}
