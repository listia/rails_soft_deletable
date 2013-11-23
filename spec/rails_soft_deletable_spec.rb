require "spec_helper"

describe RailsSoftDeletable do
  let (:model) { IntegerModel.create! }
  let (:decimal_model) { DecimalModel.create! }
  let (:integer_model) { IntegerModel.create! }

  context "#destroy" do
    it "marks deleted_at column" do
      Timecop.freeze(Time.now) do
        decimal_model.destroy
        integer_model.destroy

        decimal_deleted_at = DecimalModel.connection.select_value("SELECT deleted_at FROM #{DecimalModel.quoted_table_name} WHERE #{DecimalModel.primary_key} = #{decimal_model.id}")
        integer_deleted_at = IntegerModel.connection.select_value("SELECT deleted_at FROM #{IntegerModel.quoted_table_name} WHERE #{IntegerModel.primary_key} = #{integer_model.id}")

        expect(decimal_deleted_at).to eq(("%0.6f" % Time.now.to_f).to_f)
        expect(integer_deleted_at.to_i).to eq(Time.now.to_i)
      end
    end

    it "soft deletes the record" do
      Timecop.freeze(Time.now) do
        decimal_model.destroy
        integer_model.destroy

        expect(decimal_model.deleted_at).to eq(Time.now)
        expect(integer_model.deleted_at.to_i).to eq(Time.now.to_i)
      end
    end

    it "does not mark the deleted_at attribute as changed" do
      model.destroy

      expect(model).to_not be_deleted_at_changed
    end

    it "marks the record as destroyed" do
      model.destroy

      expect(model).to be_destroyed
    end

    it "does not freeze the record" do
      model.destroy

      expect(decimal_model).to_not be_frozen
    end

    it "performs destroy callbacks" do
      model.destroy

      expect(model.before_destroy_called).to eq(true)
      expect(model.around_destroy_called).to eq(true)
      expect(model.after_destroy_called).to eq(true)
    end

    context "when record has already been soft deleted" do
      before do
        model.destroy
        model.reset_callback_flags!
      end

      it "does not perform destroy callbacks" do
        model.destroy

        expect(model.before_destroy_called).to be_nil
        expect(model.around_destroy_called).to be_nil
        expect(model.after_destroy_called).to be_nil
      end

      it "hard deletes the record from the database" do
        model.destroy

        count = model.class.connection.select_value("SELECT COUNT(*) FROM #{model.class.quoted_table_name} WHERE #{model.class.primary_key} = #{model.id}")
        expect(count).to eq(0)
      end
    end
  end

  context "#delete" do
    it "marks deleted_at column" do
      Timecop.freeze(Time.now) do
        decimal_model.delete
        integer_model.delete

        decimal_deleted_at = DecimalModel.connection.select_value("SELECT deleted_at FROM #{DecimalModel.quoted_table_name} WHERE #{DecimalModel.primary_key} = #{decimal_model.id}")
        integer_deleted_at = IntegerModel.connection.select_value("SELECT deleted_at FROM #{IntegerModel.quoted_table_name} WHERE #{IntegerModel.primary_key} = #{integer_model.id}")

        expect(decimal_deleted_at).to eq(("%0.6f" % Time.now.to_f).to_f)
        expect(integer_deleted_at.to_i).to eq(Time.now.to_i)
      end
    end

    it "soft deletes the record" do
      Timecop.freeze(Time.now) do
        decimal_model.delete
        integer_model.delete

        expect(decimal_model.deleted_at).to eq(Time.now)
        expect(integer_model.deleted_at.to_i).to eq(Time.now.to_i)
      end
    end

    it "does not mark the deleted_at attribute as changed" do
      model.delete

      expect(model).to_not be_deleted_at_changed
    end

    it "marks the record as destroyed" do
      model.delete

      expect(model).to be_destroyed
    end

    it "does not freeze the record" do
      model.delete

      expect(decimal_model).to_not be_frozen
    end

    it "does not perform destroy callbacks" do
      model.delete

      expect(model.before_destroy_called).to be_nil
      expect(model.around_destroy_called).to be_nil
      expect(model.after_destroy_called).to be_nil
    end

    context "when record has already been soft deleted" do
      before do
        model.delete
      end

      it "does not perform destroy callbacks" do
        model.delete

        expect(model.before_destroy_called).to be_nil
        expect(model.around_destroy_called).to be_nil
        expect(model.after_destroy_called).to be_nil
      end

      it "hard deletes the record from the database" do
        model.delete

        count = model.class.connection.select_value("SELECT COUNT(*) FROM #{model.class.quoted_table_name} WHERE #{model.class.primary_key} = #{model.id}")
        expect(count).to eq(0)
      end
    end
  end

  context "#hard_destroy!" do
    it "hard deletes the record from the database" do
      model.hard_destroy!

      count = model.class.connection.select_value("SELECT COUNT(*) FROM #{model.class.quoted_table_name} WHERE #{model.class.primary_key} = #{model.id}")
      expect(count).to eq(0)
    end

    it "performs destroy callbacks" do
      model.hard_destroy!

      expect(model.before_destroy_called).to eq(true)
      expect(model.around_destroy_called).to eq(true)
      expect(model.after_destroy_called).to eq(true)
    end
  end

  context "#hard_delete!" do
    it "hard deletes the record from the database" do
      model.hard_delete!

      count = model.class.connection.select_value("SELECT COUNT(*) FROM #{model.class.quoted_table_name} WHERE #{model.class.primary_key} = #{model.id}")
      expect(count).to eq(0)
    end

    it "performs destroy callbacks" do
      model.hard_delete!

      expect(model.before_destroy_called).to be_nil
      expect(model.around_destroy_called).to be_nil
      expect(model.after_destroy_called).to be_nil
    end
  end

  context "#restore!" do
  end
end
